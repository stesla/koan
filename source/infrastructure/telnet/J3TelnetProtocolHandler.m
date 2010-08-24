//
// J3TelnetProtocolHandler.m
//
// Copyright (c) 2010 3James Software.
//

#import "J3TelnetProtocolHandler.h"
#import "J3WriteBuffer.h"

static NSArray *offerableTerminalTypes;
static NSArray *acceptableCharsets;
static NSArray *offerableCharsets;

#pragma mark -

@interface J3TelnetProtocolHandler (Private)

- (void) deallocOptions;
- (void) forOption: (uint8_t) option allowWill: (BOOL) willValue allowDo: (BOOL) doValue;
- (void) initializeOptions;
- (void) negotiateOptions;
- (void) sendCommand: (uint8_t) command withByte: (uint8_t) byte;
- (void) sendEscapedByte: (uint8_t) byte;

@end

#pragma mark -

@interface J3TelnetProtocolHandler (Subnegotiation)

- (void) sendSubnegotiationWithBytes: (const uint8_t *) payloadBytes length: (unsigned) payloadLength;
- (void) sendSubnegotiationWithData: (NSData *) payloadData;

- (void) handleCharsetSubnegotiation: (NSData *) subnegotiationData;
- (void) sendCharsetAcceptedSubnegotiationForCharset: (NSString *) charset;
- (void) sendCharsetRejectedSubnegotiation;
- (void) sendCharsetRequestSubnegotiation;
- (void) sendCharsetTTableRejectedSubnegotiation;
- (NSStringEncoding) stringEncodingForName: (NSString *) encodingName;

- (void) handleMCCPSubnegotiation: (NSData *) subnegotiationData version: (uint8_t) versionByte;

- (void) handleMSSPSubnegotiation: (NSData *) subnegotiationData;
- (void) logMSSPVariableData: (NSData *) variableData valueData: (NSData *) valueData;

- (void) handleTerminalTypeSubnegotiation: (NSData *) subnegotiationData;
- (void) sendTerminalTypeSubnegotiation;

@end

#pragma mark -

@implementation J3TelnetProtocolHandler

@synthesize connectionState;

+ (void) initialize
{
  offerableTerminalTypes = [[NSArray alloc] initWithObjects: @"KOAN", @"UNKNOWN", @"UNKNOWN", nil];
  
  acceptableCharsets = [[NSArray alloc] initWithObjects: @"UTF-8", @"ISO-8859-1", @"ISO_8859-1", @"ISO_8859-1:1987", @"ISO-IR-100", @"LATIN1", @"L1", @"IBM819", @"CP819", @"CSISOLATIN1", @"US-ASCII", @"ASCII", @"ANSI_X3.4-1968", @"ISO-IR-6", @"ANSI_X3.4-1986", @"ISO_646.IRV:1991", @"US", @"ISO646-US", @"IBM367", @"CP367", @"CSASCII", nil];
  
  offerableCharsets = [[NSArray alloc] initWithObjects: @"UTF-8", @"ISO-8859-1", @"US-ASCII", nil];
}

+ (id) protocolHandlerWithStack: (J3ProtocolStack *) stack connectionState: (J3TelnetConnectionState *) telnetConnectionState
{
  return [[[self alloc] initWithStack: stack connectionState: telnetConnectionState] autorelease];
}

- (id) initWithStack: (J3ProtocolStack *) stack connectionState: (J3TelnetConnectionState *) telnetConnectionState
{
  if (!(self = [super initWithStack: stack]))
    return nil;
  
  subnegotiationBuffer = [[NSMutableData alloc] initWithCapacity: 64];
  
  connectionState = [telnetConnectionState retain];
  stateMachine = [[J3TelnetStateMachine stateMachine] retain];
  receivedCR = NO;
  optionRequestSent = NO;
  
  [self initializeOptions];
  return self;
}

- (void) dealloc
{
  [self deallocOptions];
  [subnegotiationBuffer release];
  [connectionState release];
  [stateMachine release];
  [super dealloc];
}

- (NSObject <J3TelnetProtocolHandlerDelegate> *) delegate
{
  return delegate;
}

- (void) setDelegate: (NSObject <J3TelnetProtocolHandlerDelegate> *) object
{
  delegate = object;
}

- (void) disableOptionForHim: (uint8_t) option
{
  if (stateMachine.telnetConfirmed)
    [options[option] disableHim];
}

- (void) disableOptionForUs: (uint8_t) option
{
  if (stateMachine.telnetConfirmed)
    [options[option] disableUs];
}

- (void) enableOptionForHim: (uint8_t) option
{
  if (stateMachine.telnetConfirmed)
    [options[option] enableHim];
}

- (void) enableOptionForUs: (uint8_t) option
{
  if (stateMachine.telnetConfirmed)
    [options[option] enableUs];
}

- (BOOL) optionYesForHim: (uint8_t) option
{
  return [options[option] heIsYes];
}

- (BOOL) optionYesForUs: (uint8_t) option
{
  return [options[option] weAreYes];
}

- (void) shouldAllowWill: (BOOL) value forOption: (uint8_t) option
{
  [options[option] heIsAllowedToUse: value];
}

- (void) shouldAllowDo: (BOOL) value forOption: (uint8_t) option
{
  [options[option] weAreAllowedToUse: value];
}

- (BOOL) telnetConfirmed
{
  return stateMachine.telnetConfirmed;
}

#pragma mark -
#pragma mark J3TelnetProtocolHandler protocol

- (void) bufferSubnegotiationByte: (uint8_t) byte
{
  [subnegotiationBuffer appendBytes: &byte length: 1];
}

- (void) bufferTextByte: (uint8_t) byte
{
  if (receivedCR && byte != '\r')
  {
    receivedCR = NO;
    if (byte == '\0')
    {
      [protocolStack parseByte: '\r' previousProtocolHandler: self];
    }
    else
      [protocolStack parseByte: byte previousProtocolHandler: self];
  } 
  else if (byte == '\r')
    receivedCR = YES;
  else
    [protocolStack parseByte: byte previousProtocolHandler: self];
}

- (void) handleBufferedSubnegotiation
{
  if ([subnegotiationBuffer length] == 0)
  {
    [self log: @"Telnet irregularity: Received zero-length subnegotiation."];
  }
  
  const uint8_t *bytes = [subnegotiationBuffer bytes];
  
  switch (bytes[0])
  {
    case J3TelnetOptionTerminalType:
      [self handleTerminalTypeSubnegotiation: subnegotiationBuffer];
      break;
      
    case J3TelnetOptionCharset:
      [self handleCharsetSubnegotiation: subnegotiationBuffer];
      break;
      
    case J3TelnetOptionMSSP:
      [self handleMSSPSubnegotiation: subnegotiationBuffer];
      break;
      
    case J3TelnetOptionMCCP1:
      [self handleMCCPSubnegotiation: subnegotiationBuffer version: J3TelnetOptionMCCP1];
      break;
      
    case J3TelnetOptionMCCP2:
      [self handleMCCPSubnegotiation: subnegotiationBuffer version: J3TelnetOptionMCCP2];
      break;
      
    default:
      [self log: @"Unknown subnegotation for option %@. [%@]", [self optionNameForByte: bytes[0]], subnegotiationBuffer];
      break;
  }
  
  [subnegotiationBuffer setData: [NSData data]];
}

- (void) log: (NSString *) message, ...
{
  va_list args;
  va_start (args, message);
  
  [delegate log: message arguments: args];
  
  va_end (args);
}

- (NSString *) optionNameForByte: (uint8_t) byte
{
  switch (byte)
  {
    case J3TelnetOptionTransmitBinary:
      return @"TRANSMIT-BINARY";
      
    case J3TelnetOptionEcho:
      return @"ECHO";
      
  	case J3TelnetOptionSuppressGoAhead:
  		return @"SUPPRESS-GO-AHEAD";
      
    case J3TelnetOptionStatus:
      return @"STATUS";
  		
  	case J3TelnetOptionTimingMark:
  		return @"TIMING-MARK";
  		
  	case J3TelnetOptionTerminalType:
  		return @"TERMINAL-TYPE";
  		
  	case J3TelnetOptionEndOfRecord:
  		return @"END-OF-RECORD";
  		
  	case J3TelnetOptionNegotiateAboutWindowSize:
  		return @"NEGOTIATE-ABOUT-WINDOW-SIZE";
      
    case J3TelnetOptionTerminalSpeed:
      return @"TERMINAL-SPEED";
      
    case J3TelnetOptionToggleFlowControl:
      return @"TOGGLE-FLOW-CONTROL";
  		
  	case J3TelnetOptionLineMode:
  		return @"LINEMODE";
      
    case J3TelnetOptionXDisplayLocation:
      return @"X-DISPLAY-LOCATION";
      
    case J3TelnetOptionEnvironment:
      return @"ENVIRON";
      
    case J3TelnetOptionNewEnvironment:
      return @"NEW-ENVIRON";
      
    case J3TelnetOptionCharset:
      return @"CHARSET";
      
    case J3TelnetOptionStartTLS:
      return @"START-TLS";
      
    case J3TelnetOptionMSDP:
      return @"MSDP";
      
    case J3TelnetOptionMSSP:
      return @"MSSP";
  		
  	case J3TelnetOptionMCCP1:
  		return @"COMPRESS (MCCP1)";
  		
  	case J3TelnetOptionMCCP2:
  		return @"COMPRESS2 (MCCP2)";
  		
    case J3TelnetOptionMSP:
      return @"MSP";
      
    case J3TelnetOptionMXP:
      return @"MXP";
      
    case J3TelnetOptionZMP:
      return @"ZMP";
      
    case J3TelnetOptionAardwolf:
      return @"AARDWOLF";
      
    case J3TelnetOptionATCP:
      return @"ATCP";
      
    case J3TelnetOptionGMCP:
      return @"GMCP";
      
  	default:
  		return [NSString stringWithFormat: @"%u (unknown option)", (unsigned) byte];
  }
}

- (void) receivedDo: (uint8_t) option
{
  [options[option] receivedDo];
  
  if (option == J3TelnetOptionCharset)
    [self sendCharsetRequestSubnegotiation];
}

- (void) receivedDont: (uint8_t) option
{
  [options[option] receivedDont];
}

- (void) receivedWill: (uint8_t) option
{
  [options[option] receivedWill];
  
  if (option == J3TelnetOptionMCCP2)
    [self forOption: J3TelnetOptionMCCP1 allowWill: NO allowDo: NO];
}

- (void) receivedWont: (uint8_t) option
{
  [options[option] receivedWont];
}

#pragma mark -
#pragma mark J3ProtocolHandler overrides

- (void) parseByte: (uint8_t) byte
{
  [stateMachine parse: byte forProtocol: self];
  
  if (!optionRequestSent && stateMachine.telnetConfirmed)
  {
    optionRequestSent = YES;
    [self negotiateOptions];
  }
}

- (NSData *) headerForPreprocessedData
{
  return nil;
}

- (NSData *) footerForPreprocessedData
{
  NSMutableData *footerData = [NSMutableData dataWithCapacity: 4];
  
  if ([self optionYesForUs: J3TelnetOptionEndOfRecord])
  {
    uint8_t endOfRecordBytes[] = {J3TelnetInterpretAsCommand, J3TelnetEndOfRecord};
    [footerData appendBytes: &endOfRecordBytes length: 2];
  }
  
  if (stateMachine.telnetConfirmed && ![self optionYesForUs: J3TelnetOptionSuppressGoAhead])
  {
    uint8_t goAheadBytes[] = {J3TelnetInterpretAsCommand, J3TelnetGoAhead};
    [footerData appendBytes: &goAheadBytes length: 2];
  }
  
  return footerData;
}

- (void) preprocessByte: (uint8_t) byte
{
  if (byte == J3TelnetInterpretAsCommand)
    [protocolStack preprocessByte: byte previousProtocolHandler: self];
  [protocolStack preprocessByte: byte previousProtocolHandler: self];
}

#pragma mark -
#pragma mark J3TelnetOptionDelegate protocol

- (void) do: (uint8_t) option
{
  [self log: @"    Sent: IAC DO %@.", [self optionNameForByte: option]];
  [self sendCommand: J3TelnetDo withByte: option];
}

- (void) dont: (uint8_t) option
{
  [self log: @"    Sent: IAC DONT %@.", [self optionNameForByte: option]];
  [self sendCommand: J3TelnetDont withByte: option];
}

- (void) will: (uint8_t) option
{
  [self log: @"    Sent: IAC WILL %@.", [self optionNameForByte: option]];
  [self sendCommand: J3TelnetWill withByte: option];
}

- (void) wont: (uint8_t) option
{
  [self log: @"    Sent: IAC WONT %@.", [self optionNameForByte: option]];
  [self sendCommand: J3TelnetWont withByte: option];
}

@end

#pragma mark -

@implementation J3TelnetProtocolHandler (Private)

- (void) deallocOptions
{
  for (uint8_t i = 0; i < TELNET_OPTION_MAX; i++)
    [options[i] release];
}

- (void) forOption: (uint8_t) option allowWill: (BOOL) willValue allowDo: (BOOL) doValue
{
  [self shouldAllowWill: willValue forOption: option];
  [self shouldAllowDo: doValue forOption: option];
}

- (void) initializeOptions
{
  for (uint8_t i = 0; i < TELNET_OPTION_MAX; i++)
    options[i] = [[J3TelnetOption alloc] initWithOption: i delegate: self];
  
  [self forOption: J3TelnetOptionTransmitBinary allowWill: YES allowDo: YES];
  [self forOption: J3TelnetOptionSuppressGoAhead allowWill: YES allowDo: YES];
  [self forOption: J3TelnetOptionTerminalType allowWill: NO allowDo: YES];
  [self forOption: J3TelnetOptionEndOfRecord allowWill: YES allowDo: YES];
  [self forOption: J3TelnetOptionCharset allowWill: YES allowDo: YES];
  [self forOption: J3TelnetOptionMSSP allowWill: YES allowDo: NO];
  [self forOption: J3TelnetOptionMCCP1 allowWill: YES allowDo: NO];
  [self forOption: J3TelnetOptionMCCP2 allowWill: YES allowDo: NO];
}

- (void) negotiateOptions
{
  [self enableOptionForUs: J3TelnetOptionSuppressGoAhead];
  
  // PennMUSH does not respond well to IAC GA, but it ignores
  // IAC WILL SGA.  If we send IAC DO SGA it will request that
  // we also IAC DO SGA, so that results in a good set of options.
  [self enableOptionForHim: J3TelnetOptionSuppressGoAhead];
}

- (void) sendCommand: (uint8_t) command withByte: (uint8_t) byte
{
  uint8_t bytes[] = {J3TelnetInterpretAsCommand, command, byte};
  [delegate writeDataToSocket: [NSData dataWithBytes: bytes length: 3]];
}

- (void) sendEscapedByte: (uint8_t) byte
{
  uint8_t bytes[] = {J3TelnetInterpretAsCommand, byte};
  [delegate writeDataToSocket: [NSData dataWithBytes: bytes length: 2]];
}

@end

#pragma mark -

@implementation J3TelnetProtocolHandler (Subnegotiation)

- (void) sendSubnegotiationWithBytes: (const uint8_t *) payloadBytes length: (unsigned) payloadLength
{
  const uint8_t headerBytes[2] = {J3TelnetInterpretAsCommand, J3TelnetBeginSubnegotiation};
  const uint8_t footerBytes[2] = {J3TelnetInterpretAsCommand, J3TelnetEndSubnegotiation};
  NSMutableData *data = [NSMutableData data];
  
  [data appendBytes: headerBytes length: 2];
  [data appendBytes: payloadBytes length: payloadLength];
  [data appendBytes: footerBytes length: 2];
  
  [delegate writeDataToSocket: data];
}

- (void) sendSubnegotiationWithData: (NSData *) payloadData
{
  [self sendSubnegotiationWithBytes: [payloadData bytes] length: [payloadData length]];
}

#pragma mark -
#pragma mark CHARSET

- (void) handleCharsetSubnegotiation: (NSData *) subnegotiationData
{
  const uint8_t *bytes = [subnegotiationData bytes];
  unsigned length = [subnegotiationData length];
  
  if (![self optionYesForHim: J3TelnetOptionCharset])
    [self log: @"Telnet irregularity: Server sent %@ REQUEST without WILL %@.", [self optionNameForByte: bytes[0]], [self optionNameForByte: bytes[0]]];
  
  if (length == 1)
  {
    [self log: @"Telnet irregularity: Invalid length of %u for %@ subnegotiation. [%@]", length, [self optionNameForByte: bytes[0]], subnegotiationData];
    return;
  }
  
  switch (bytes[1])
  {
    case J3TelnetCharsetRequest:
    {
      unsigned byteOffset = 2;
      BOOL serverOfferedTranslationTable = NO;
      uint8_t translationTableVersion = 0;
      
      if (length == 2)
      {
        [self log: @"Telnet irregularity: Invalid length of %u for %@ REQUEST subnegotiation. [%@]", length, [self optionNameForByte: bytes[0]], subnegotiationData];
        return;
      }
      
      if (length > 10 && strncmp ((char *) bytes + 2, "[TTABLE]", 8) == 0)
      {
        serverOfferedTranslationTable = YES;
        
        byteOffset += strlen ("[TTABLE]");
        translationTableVersion = bytes[byteOffset++];
        if (translationTableVersion != 1)
          [self log: @"Telnet irregularity: Invalid TTABLE version %u for %@ REQUEST subnegotiation. [%@]", length, [self optionNameForByte: bytes[0]], subnegotiationData];
      }
      
      uint8_t separatorCharacter = bytes[byteOffset];
      NSString *separatorCharacterString = [[[NSString alloc] initWithBytes: &separatorCharacter length: 1 encoding: NSASCIIStringEncoding] autorelease];
      
      if (separatorCharacter == J3TelnetInterpretAsCommand)
        [self log: @"Telnet irregularity: IAC used as separator in %@ REQUEST subnegotiation. [%@]", length, [self optionNameForByte: bytes[0]], subnegotiationData];
      
      NSString *offeredCharsetsString = [[[NSString alloc] initWithBytes: bytes + byteOffset + 1 length: length - byteOffset - 1 encoding: NSASCIIStringEncoding] autorelease];
      NSArray *offeredCharsets = [offeredCharsetsString componentsSeparatedByString: separatorCharacterString];
      
      if (serverOfferedTranslationTable)
        [self log: @"Received: IAC SB %@ REQUEST [TTABLE] %u <%@> IAC SE.", [self optionNameForByte: bytes[0]], translationTableVersion, [offeredCharsets componentsJoinedByString: @" "]];
      else
        [self log: @"Received: IAC SB %@ REQUEST <%@> IAC SE.", [self optionNameForByte: bytes[0]], [offeredCharsets componentsJoinedByString: @" "]];
      
      for (NSString *charset in offeredCharsets)
      {
        if ([acceptableCharsets containsObject: charset])
        {
          self.connectionState.stringEncoding = [self stringEncodingForName: charset];
          [self sendCharsetAcceptedSubnegotiationForCharset: charset];
          
          if (self.connectionState.stringEncoding == NSASCIIStringEncoding)
          {
            [self disableOptionForUs: J3TelnetOptionTransmitBinary];
            [self disableOptionForHim: J3TelnetOptionTransmitBinary];
          }
          else
          {
            [self enableOptionForUs: J3TelnetOptionTransmitBinary];
            [self enableOptionForHim: J3TelnetOptionTransmitBinary];
          }
          return;
        }
      }
      
      [self sendCharsetRejectedSubnegotiation];
      return;
    }
      
    case J3TelnetCharsetAccepted:
    {
      if (self.connectionState.charsetNegotiationStatus != J3TelnetCharsetNegotiationActive)
      {
        [self log: @"Telnet irregularity: Received %@ ACCEPTED subnegotiation, but no active negotiation in progress.", length, [self optionNameForByte: bytes[0]]];
      }
      
      if (length == 2)
      {
        [self log: @"Telnet irregularity: Invalid length of %u for %@ ACCEPTED subnegotiation. [%@]", length, [self optionNameForByte: bytes[0]], subnegotiationData];
        return;
      }
      
      NSString *acceptedCharset = [[[NSString alloc] initWithBytes: bytes + 2 length: length - 2 encoding: NSASCIIStringEncoding] autorelease];
      
      self.connectionState.charsetNegotiationStatus = J3TelnetCharsetNegotiationInactive;
      
      if ([acceptableCharsets containsObject: acceptedCharset])
      {
        self.connectionState.stringEncoding = [self stringEncodingForName: acceptedCharset];
        
        if (self.connectionState.stringEncoding == NSASCIIStringEncoding)
        {
          [self disableOptionForUs: J3TelnetOptionTransmitBinary];
          [self disableOptionForHim: J3TelnetOptionTransmitBinary];
        }
        else
        {
          [self enableOptionForUs: J3TelnetOptionTransmitBinary];
          [self enableOptionForHim: J3TelnetOptionTransmitBinary];
        }
        
        [self log: @"Received: IAC SB %@ ACCEPTED %@ IAC SE.", [self optionNameForByte: bytes[0]], acceptedCharset];
      }
      else
        [self log: @"Telnet irregularity: Server sent %@ ACCEPTED subnegotiation for %@, which was not offered.", [self optionNameForByte: bytes[0]], acceptedCharset];
      
      return;
    }
      
    case J3TelnetCharsetRejected:
      if (self.connectionState.charsetNegotiationStatus == J3TelnetCharsetNegotiationInactive)
        [self log: @"Telnet irregularity: Received %@ REJECTED subnegotiation, but no active negotiation in progress.", length, [self optionNameForByte: bytes[0]]];
      
      self.connectionState.charsetNegotiationStatus = J3TelnetCharsetNegotiationInactive;
      
      if (length > 2)
        [self log: @"Telnet irregularity: Invalid length of %u for %@ REJECTED subnegotiation. [%@]", length, [self optionNameForByte: bytes[0]], subnegotiationData];
      else
        [self log: @"Received: IAC SB %@ REJECTED IAC SE.", [self optionNameForByte: bytes[0]]];
      return;
      
    case J3TelnetCharsetTTableIs:
      [self log: @"Telnet irregularity: Received %@ TTABLE-IS subnegotiation without offering to accept a translation table. [%@]", length, [self optionNameForByte: bytes[0]], subnegotiationData];
      [self sendCharsetTTableRejectedSubnegotiation];
      return;
      
    case J3TelnetCharsetTTableAck:
      [self log: @"Telnet irregularity: Received %@ TTABLE-ACK subnegotiation without offering a translation table. [%@]", length, [self optionNameForByte: bytes[0]], subnegotiationData];
      return;
      
    case J3TelnetCharsetTTableNak:
      [self log: @"Telnet irregularity: Received %@ TTABLE-NAK subnegotiation without offering a translation table. [%@]", length, [self optionNameForByte: bytes[0]], subnegotiationData];
      return;
      
    case J3TelnetCharsetTTableRejected:
      [self log: @"Telnet irregularity: Received %@ TTABLE-REJECTED subnegotiation without offering a translation table. [%@]", length, [self optionNameForByte: bytes[0]], subnegotiationData];
      return;
      
    default:
      [self log: @"Telnet irregularity: %u is an unsupported %@ subnegotiation request. [%@]", bytes[1], [self optionNameForByte: bytes[0]], subnegotiationData];
  }
}

- (void) sendCharsetAcceptedSubnegotiationForCharset: (NSString *) charset
{
  uint8_t bytes[] = {J3TelnetOptionCharset, J3TelnetCharsetAccepted};
  NSMutableData *charsetAcceptedData = [NSMutableData dataWithBytes: bytes length: 2];
  
  [charsetAcceptedData appendBytes: [charset cStringUsingEncoding: NSASCIIStringEncoding]
                            length: [charset lengthOfBytesUsingEncoding: NSASCIIStringEncoding]];
  
  if (self.connectionState.charsetNegotiationStatus == J3TelnetCharsetNegotiationActive)
    self.connectionState.charsetNegotiationStatus = J3TelnetCharsetNegotiationIgnoreRejected;
  else
    self.connectionState.charsetNegotiationStatus = J3TelnetCharsetNegotiationInactive;
  
  [self sendSubnegotiationWithData: charsetAcceptedData];
  [self log: @"    Sent: IAC SB %@ ACCEPTED %@ IAC SE.", [self optionNameForByte: J3TelnetOptionCharset], charset];
}

- (void) sendCharsetRejectedSubnegotiation
{
  uint8_t bytes[] = {J3TelnetOptionCharset, J3TelnetCharsetRejected};
  NSMutableData *charsetRejectedData = [NSMutableData dataWithBytes: bytes length: 2];
  
  if (self.connectionState.charsetNegotiationStatus == J3TelnetCharsetNegotiationActive)
    self.connectionState.charsetNegotiationStatus = J3TelnetCharsetNegotiationIgnoreRejected;
  else
    self.connectionState.charsetNegotiationStatus = J3TelnetCharsetNegotiationInactive;
  
  [self sendSubnegotiationWithData: charsetRejectedData];
  [self log: @"    Sent: IAC SB %@ REJECTED IAC SE.", [self optionNameForByte: J3TelnetOptionCharset]];
}

- (void) sendCharsetRequestSubnegotiation
{
  if (self.connectionState.charsetNegotiationStatus == J3TelnetCharsetNegotiationActive)
    return;
  
  uint8_t bytes[] = {J3TelnetOptionCharset, J3TelnetCharsetRequest};
  NSMutableData *charsetRequestData = [NSMutableData dataWithBytes: bytes length: 2];
  
  for (NSString *charset in offerableCharsets)
  {
    uint8_t separator = ';';
    [charsetRequestData appendBytes: &separator length: 1];
    [charsetRequestData appendBytes: [charset cStringUsingEncoding: NSASCIIStringEncoding]
                             length: [charset lengthOfBytesUsingEncoding: NSASCIIStringEncoding]];
  }
  
  self.connectionState.charsetNegotiationStatus = J3TelnetCharsetNegotiationActive;
  
  [self sendSubnegotiationWithData: charsetRequestData];
  [self log: @"    Sent: IAC SB %@ REQUEST <%@> IAC SE.", [self optionNameForByte: J3TelnetOptionCharset], [offerableCharsets componentsJoinedByString: @" "]];
}

- (void) sendCharsetTTableRejectedSubnegotiation
{
  uint8_t bytes[] = {J3TelnetOptionCharset, J3TelnetCharsetTTableRejected};
  NSMutableData *charsetRejectedData = [NSMutableData dataWithBytes: bytes length: 2];
  
  [self sendSubnegotiationWithData: charsetRejectedData];
  [self log: @"    Sent: IAC SB %@ TTABLE-REJECTED IAC SE.", [self optionNameForByte: J3TelnetOptionCharset]];
}

- (NSStringEncoding) stringEncodingForName: (NSString *) encodingName
{
  if ([encodingName caseInsensitiveCompare: @"UTF-8"] == NSOrderedSame)
    return NSUTF8StringEncoding;
  
  else if ([encodingName caseInsensitiveCompare: @"ISO-8859-1"] == NSOrderedSame
           || [encodingName caseInsensitiveCompare: @"ISO_8859-1"] == NSOrderedSame
           || [encodingName caseInsensitiveCompare: @"ISO_8859-1:1987"] == NSOrderedSame
           || [encodingName caseInsensitiveCompare: @"ISO-IR-100"] == NSOrderedSame
           || [encodingName caseInsensitiveCompare: @"LATIN1"] == NSOrderedSame
           || [encodingName caseInsensitiveCompare: @"L1"] == NSOrderedSame
           || [encodingName caseInsensitiveCompare: @"IBM819"] == NSOrderedSame
           || [encodingName caseInsensitiveCompare: @"CP819"] == NSOrderedSame
           || [encodingName caseInsensitiveCompare: @"CSISOLATIN1"] == NSOrderedSame)
    return NSISOLatin1StringEncoding;
  
  /*
  else if ([encodingName caseInsensitiveCompare: @"US-ASCII"] == NSOrderedSame
           || [encodingName caseInsensitiveCompare: @"ASCII"] == NSOrderedSame
           || [encodingName caseInsensitiveCompare: @"ANSI_X3.4-1968"] == NSOrderedSame
           || [encodingName caseInsensitiveCompare: @"ISO-IR-6"] == NSOrderedSame
           || [encodingName caseInsensitiveCompare: @"ANSI_X3.4-1986"] == NSOrderedSame
           || [encodingName caseInsensitiveCompare: @"ISO_646.IRV:1991"] == NSOrderedSame
           || [encodingName caseInsensitiveCompare: @"US"] == NSOrderedSame
           || [encodingName caseInsensitiveCompare: @"ISO646-US"] == NSOrderedSame
           || [encodingName caseInsensitiveCompare: @"IBM367"] == NSOrderedSame
           || [encodingName caseInsensitiveCompare: @"CP367"] == NSOrderedSame
           || [encodingName caseInsensitiveCompare: @"CSASCII"] == NSOrderedSame)
    return NSASCIIStringEncoding;
  */
  
  // There is no "invalid encoding" value, so default to NVT ASCII.
  else return NSASCIIStringEncoding;
}

#pragma mark -
#pragma mark MCCP

- (void) handleMCCPSubnegotiation: (NSData *) subnegotiationData version: (uint8_t) versionByte
{
  const uint8_t *bytes = [subnegotiationData bytes];
  unsigned length = [subnegotiationData length];
  
  if (length != 1)
  {
    [self log: @"MCCP irregularity: %@ subnegotiation length is not 1. [%@]", [self optionNameForByte: versionByte], subnegotiationData];
    return;
  }
  
  if (bytes[0] != versionByte)
  {
    [self log: @"MCCP irregularity: First byte is not %@. [%@]", [self optionNameForByte: versionByte], subnegotiationData];
    return;
  }
  
  switch (versionByte)
  {
    case J3TelnetOptionMCCP1:
      [self log: @"Received: IAC SB %@ WILL SE.", [self optionNameForByte: versionByte]];
      break;
      
    case J3TelnetOptionMCCP2:
      [self log: @"Received: IAC SB %@ IAC SE.", [self optionNameForByte: versionByte]];
      break;
  }
  
  self.connectionState.incomingStreamCompressed = YES;
}

#pragma mark -
#pragma mark MSSP

- (void) handleMSSPSubnegotiation: (NSData *) subnegotiationData
{
  const uint8_t *bytes = [subnegotiationData bytes];
  unsigned length = [subnegotiationData length];
  
  if (length == 1)
  {
    [self log: @"MSSP irregularity: %@ subnegotiation length of 1. [%@]", [self optionNameForByte: bytes[0]], subnegotiationData];
    return;
  }
  
  if (bytes[1] != 1)
  {
    [self log: @"MSSP irregularity: First byte is not MSSP-VAR. [%@]", subnegotiationData];
    return;
  }
  
  NSMutableData *variableData = [NSMutableData data];
  NSMutableData *valueData = [NSMutableData data];
  BOOL readingValue = NO;
  
  [self log: @"Received: IAC SB %@ [] IAC SE.", [self optionNameForByte: J3TelnetOptionMSSP]];
  
  for (unsigned i = 2; i < length; i++)
  {
    switch (bytes[i])
    {
      case 1:
        readingValue = NO;
        [self logMSSPVariableData: variableData valueData: valueData];
        [variableData setData: [NSMutableData data]];
        [valueData setData: [NSMutableData data]];
        continue;
        
      case 2:
        readingValue = YES;
        continue;
        
      default:
        if (readingValue)
          [valueData appendBytes: bytes + i length: 1];
        else
          [variableData appendBytes: bytes + i length: 1];
    }
  }
  
  if (!readingValue)
  {
    [self log: @"MSSP irregularity: Mismatched number of MSSP-VAR and MSSP-VAL. [%@]", subnegotiationData];
    return;
  }
  
  [self logMSSPVariableData: variableData valueData: valueData];
}

- (void) logMSSPVariableData: (NSData *) variableData valueData: (NSData *) valueData
{
  [self log: @"    MSSP:   %@ = %@.", [[[NSString alloc] initWithData: variableData encoding: NSASCIIStringEncoding] autorelease],
   [[[NSString alloc] initWithData: valueData encoding: NSASCIIStringEncoding] autorelease]];
}

#pragma mark -
#pragma mark TERMINAL-TYPE

- (void) handleTerminalTypeSubnegotiation: (NSData *) subnegotiationData
{
  const uint8_t *bytes = [subnegotiationData bytes];
  unsigned length = [subnegotiationData length];
  
  if (length != 2)
  {
    [self log: @"Telnet irregularity: Invalid length of %u for %@ subnegotiation request. [%@]", length, [self optionNameForByte: bytes[0]], subnegotiationData];
    return;
  }
  
  if (bytes[1] != J3TelnetTerminalTypeSend)
  {
    [self log: @"Telnet irregularity: %u is not a known %@ subnegotiation request. [%@]", bytes[1], [self optionNameForByte: bytes[0]], subnegotiationData];
    return;
  }
  
  [self log: @"Received: IAC SB %@ SEND IAC SE.", [self optionNameForByte: bytes[0]]];
  [self sendTerminalTypeSubnegotiation];
}

- (void) sendTerminalTypeSubnegotiation
{
  uint8_t prefixBytes[] = {J3TelnetOptionTerminalType, J3TelnetTerminalTypeIs};
  NSMutableData *terminalTypeData = [NSMutableData dataWithBytes: prefixBytes length: 2];
  
  NSString *terminalType = [offerableTerminalTypes objectAtIndex: self.connectionState.nextTerminalTypeIndex++];
  
  if (self.connectionState.nextTerminalTypeIndex >= [offerableTerminalTypes count])
    self.connectionState.nextTerminalTypeIndex = 0;
  
  [terminalTypeData appendBytes: [terminalType cStringUsingEncoding: NSASCIIStringEncoding]
                         length: [terminalType lengthOfBytesUsingEncoding: NSASCIIStringEncoding]];
  
  [self sendSubnegotiationWithData: terminalTypeData];
  [self log: @"    Sent: IAC SB %@ IS %@ IAC SE.", [self optionNameForByte: J3TelnetOptionTerminalType], terminalType];
}

@end

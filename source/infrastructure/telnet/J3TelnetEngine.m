//
// J3TelnetEngine.m
//
// Copyright (c) 2007 3James Software.
//

#import "J3ReadBuffer.h"
#import "J3TelnetEngine.h"
#import "J3TelnetTextState.h"
#import "J3WriteBuffer.h"

@interface J3TelnetEngine (Private)

- (void) deallocOptions;
- (void) forOption: (uint8_t) option allowWill: (BOOL) willValue allowDo: (BOOL) doValue;
- (void) initializeOptions;
- (void) negotiateOptions;
- (void) parseByte: (uint8_t) byte;
- (void) sendCommand: (uint8_t) command withByte: (uint8_t) byte;
- (void) sendEscapedByte: (uint8_t) byte;

@end

#pragma mark -

@implementation J3TelnetEngine

+ (id) engine
{
  return [[[self alloc] init] autorelease];
}

- (id) init
{
  if (![super init])
    return nil;
  [self at: &state put: [J3TelnetTextState state]];
  [self initializeOptions];
  telnetConfirmed = NO;
  return self;
}

- (void) confirmTelnet
{
  telnetConfirmed = YES;
}

- (void) bufferInputByte: (uint8_t) byte
{
  [delegate bufferInputByte: byte];
}

- (void) dealloc
{
  [self deallocOptions];
  [state release];
  [super dealloc];
}

- (id <J3TelnetEngineDelegate>) delegate
{
  return delegate;
}

- (void) disableOptionForHim: (uint8_t) option
{
  if (telnetConfirmed)
    [options[option] disableHim];
}

- (void) disableOptionForUs: (uint8_t) option
{
  if (telnetConfirmed)
    [options[option] disableUs];
}

- (void) enableOptionForHim: (uint8_t) option
{
  if (telnetConfirmed)
    [options[option] enableHim];
}

- (void) enableOptionForUs: (uint8_t) option
{
  if (telnetConfirmed)
    [options[option] enableUs];
}

- (void) endOfRecord
{
  if ([self optionYesForUs: J3TelnetOptionEndOfRecord])
    [self sendEscapedByte: J3TelnetEndOfRecord];
}

- (void) goAhead
{
  if (telnetConfirmed && ![self optionYesForUs: J3TelnetOptionSuppressGoAhead])
    [self sendEscapedByte: J3TelnetGoAhead];
}

- (void) log: (NSString *) message, ...
{
  va_list args;
  va_start (args, message);
  
  [delegate log: message arguments: args];
  
  va_end (args);
}

- (BOOL) optionYesForHim: (uint8_t) option
{
  return [options[option] heIsYes];
}

- (BOOL) optionYesForUs: (uint8_t) option
{
  return [options[option] weAreYes];
}

- (NSString *) optionNameForByte: (uint8_t) byte
{
  switch (byte)
  {
    case J3TelnetOptionEcho:
      return @"ECHO";
      
    case J3TelnetOptionStatus:
      return @"STATUS";
    
  	case J3TelnetOptionSuppressGoAhead:
  		return @"SUPPRESS-GO-AHEAD";
  		
  	case J3TelnetOptionTerminalType:
  		return @"TERMINAL-TYPE";
  		
  	case J3TelnetOptionEndOfRecord:
  		return @"END-OF-RECORD";
  		
  	case J3TelnetOptionNegotiateAboutWindowSize:
  		return @"NAWS";
      
    case J3TelnetOptionTerminalSpeed:
      return @"TERMINAL-SPEED";
      
    case J3TelnetOptionToggleFlowControl:
      return @"TOGGLE-FLOW-CONTROL";
  		
  	case J3TelnetOptionLineMode:
  		return @"LINEMODE";
      
    case J3TelnetOptionXDisplayLocation:
      return @"X-DISPLAY-LOCATION";
      
    case J3TelnetOptionNewEnviron:
      return @"NEW-ENVIRON";
  		
  	case J3TelnetOptionMCCP1:
  		return @"COMPRESS (MCCP1)";
  		
  	case J3TelnetOptionMCCP2:
  		return @"COMPRESS2 (MCCP2)";
  		
    case J3TelnetOptionMSP:
      return @"MSP";
      
    case J3TelnetOptionMXP:
      return @"MXP";
      
  	default:
  		return [NSString stringWithFormat: @"%u (unknown option)", (unsigned) byte];
  }
}

- (void) parseData: (NSData *) data
{
  BOOL wasConfirmed = telnetConfirmed;
  for (unsigned i = 0; i < [data length]; i++)
    [self parseByte: ((uint8_t *) [data bytes])[i]];
  if (!wasConfirmed && telnetConfirmed)
    [self negotiateOptions];
}

- (NSData *) preprocessOutput: (NSData *) data
{
  const uint8_t *bytes = [data bytes];
  NSMutableData *result = [NSMutableData dataWithCapacity: [data length]];
  for (unsigned i = 0; i < [data length]; ++i)
  {
    if (bytes[i] == J3TelnetInterpretAsCommand)
      [result appendBytes:  bytes + i length: 1];
    [result appendBytes: bytes + i length: 1];
  }
  return result;
}

- (void) receivedDo: (uint8_t) option
{
  [options[option] receivedDo];
}

- (void) receivedDont: (uint8_t) option
{
  [options[option] receivedDont];
}

- (void) receivedWill: (uint8_t) option
{
  [options[option] receivedWill];
}

- (void) receivedWont: (uint8_t) option
{
  [options[option] receivedWont];
}

- (void) shouldAllowWill: (BOOL) value forOption: (uint8_t) option;
{
  [options[option] heIsAllowedToUse: value];
}

- (void) shouldAllowDo: (BOOL) value forOption: (uint8_t) option;
{
  [options[option] weAreAllowedToUse: value];
}

- (void) setDelegate: (id <J3TelnetEngineDelegate>) object
{
  delegate = object;
}

- (BOOL) telnetConfirmed
{
  return telnetConfirmed;
}

#pragma mark -
#pragma mark J3TelnetOptionDelegate protocol

- (void) do: (uint8_t) option
{
  [self log: @"    Sent: IAC DO %@", [self optionNameForByte: option]];
  [self sendCommand: J3TelnetDo withByte: option];    
}

- (void) dont: (uint8_t) option
{
  [self log: @"    Sent: IAC DONT %@", [self optionNameForByte: option]];
  [self sendCommand: J3TelnetDont withByte: option];  
}

- (void) will: (uint8_t) option
{
  [self log: @"    Sent: IAC WILL %@", [self optionNameForByte: option]];
  [self sendCommand: J3TelnetWill withByte: option];    
}

- (void) wont: (uint8_t) option
{
  [self log: @"    Sent: IAC WONT %@", [self optionNameForByte: option]];
  [self sendCommand: J3TelnetWont withByte: option];  
}

@end

#pragma mark -

@implementation J3TelnetEngine (Private)

- (void) deallocOptions
{
  for (unsigned i = 0; i < TELNET_OPTION_MAX; ++i)
    [options[i] release];
}

- (void) forOption: (uint8_t) option allowWill: (BOOL) willValue allowDo: (BOOL) doValue
{
  [self shouldAllowWill: willValue forOption: option];
  [self shouldAllowDo: doValue forOption: option];
}

- (void) initializeOptions
{
  for (unsigned i = 0; i < TELNET_OPTION_MAX; ++i)
    options[i] = [[J3TelnetOption alloc] initWithOption: i delegate: self];
  
  [self forOption: J3TelnetOptionEndOfRecord allowWill: YES allowDo: YES];
  [self forOption: J3TelnetOptionSuppressGoAhead allowWill: YES allowDo: YES];
}

- (void) negotiateOptions
{
  [self enableOptionForUs: J3TelnetOptionSuppressGoAhead];
  // PennMUSH does not respond well to IAC GA, but it ignores
  // IAC WILL SGA.  If we send IAC DO SGA it will request that
  // we also IAC DO SGA, so that results in a good set of options.
  [self enableOptionForHim: J3TelnetOptionSuppressGoAhead];
}

- (void) parseByte: (uint8_t) byte
{
  [self at: &state put: [state parse: byte forEngine: self]];
}

- (void) sendCommand: (uint8_t) command withByte: (uint8_t) byte
{
  uint8_t bytes[] = {J3TelnetInterpretAsCommand, command, byte};
  [delegate writeData: [NSData dataWithBytes: bytes length: 3]];
}

- (void) sendEscapedByte: (uint8_t) byte
{
  uint8_t bytes[] = {J3TelnetInterpretAsCommand, byte};
  [delegate writeData: [NSData dataWithBytes: bytes length: 2]];
}

@end


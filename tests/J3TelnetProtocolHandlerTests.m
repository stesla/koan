//
// J3TelnetProtocolHandlerTests.m
//
// Copyright (c) 2010 3James Software.
//

#import "J3TelnetProtocolHandlerTests.h"

#import "J3TelnetConnectionState.h"
#import "J3TelnetConstants.h"

@interface J3TelnetProtocolHandlerTests (Private)

- (void) assertData: (NSData *) data hasBytesWithZeroTerminator: (const char *) bytes;
- (void) confirmTelnetWithDontEcho;
- (NSData *) parseBytesWithZeroTerminator: (const uint8_t *) bytes;
- (NSData *) parseCString: (const char *) string;
- (void) resetProtocolHandler;
- (void) simulateDo: (uint8_t) option;
- (void) simulateIncomingSubnegotation: (const uint8_t *) payload length: (unsigned) payloadLength;
- (void) simulateWill: (uint8_t) option;

@end

#pragma mark -

@implementation J3TelnetProtocolHandlerTests

- (void) setUp
{
  [self resetProtocolHandler];
  mockSocketData = [[NSMutableData alloc] init];
}

- (void) tearDown
{
  [protocolHandler release];
  [mockSocketData release];
}

- (void) testIACEscapedInData
{
  uint8_t bytes[] = {J3TelnetInterpretAsCommand};
  NSData *data = [NSData dataWithBytes: bytes length: 1];
  NSData *preprocessedData = [protocolHandler preprocessOutput: data];
  
  const char expectedBytes[] = {J3TelnetInterpretAsCommand, J3TelnetInterpretAsCommand, 0};
  [self assertData: preprocessedData hasBytesWithZeroTerminator: expectedBytes];
}

- (void) testTelnetNotSentWhenNotConfirmed
{
  [self resetProtocolHandler];
  [protocolHandler enableOptionForUs: 0];
  [protocolHandler enableOptionForHim: 0];
  [protocolHandler disableOptionForUs: 0];
  [protocolHandler disableOptionForHim: 0];
  [self assert: mockSocketData equals: [NSData data] message: @"telnet was written"];
}

- (void) testParsePlainText
{
  NSData *parsedData = [self parseCString: "foo"];
  [self assertData: parsedData hasBytesWithZeroTerminator: "foo"];
}

- (void) testParseLF
{
  NSData *parsedData = [self parseCString: "\n"];
  [self assertData: parsedData hasBytesWithZeroTerminator: "\n"];
}

- (void) testParseCRLF
{
  NSData *parsedData = [self parseCString: "\r\n"];
  [self assertData: parsedData hasBytesWithZeroTerminator: "\n"];
}

- (void) testParseCRNUL
{
  NSData *parsedData = [protocolHandler parseData: [NSData dataWithBytes: "\r\0" length: 2]];
  [self assertData: parsedData hasBytesWithZeroTerminator: "\r"];
}

- (void) testParseCRSomethingElse
{
  uint8_t bytes[2] = {'\r', 0};
  
  for (unsigned i = 1; i < UINT8_MAX; i++)
  {
    if (i == '\n' || i == '\r')
      continue;
    bytes[1] = i;
    NSData *parsedData = [protocolHandler parseData: [NSData dataWithBytes: bytes length: 2]];
    [self assert: parsedData equals: [NSData dataWithBytes: bytes + 1 length: 1]];
  }
}

- (void) testSubnegotiationPutsNothingInReadBuffer
{
  uint8_t bytes[9] = {J3TelnetInterpretAsCommand, J3TelnetDo, J3TelnetOptionTerminalType, J3TelnetInterpretAsCommand, J3TelnetBeginSubnegotiation, J3TelnetOptionTerminalType, J3TelnetTerminalTypeSend, J3TelnetInterpretAsCommand, J3TelnetEndSubnegotiation};
  
  NSData *parsedData = [protocolHandler parseData: [NSData dataWithBytes: bytes length: 9]];
  [self assertInt: [parsedData length] equals: 0];
}

- (void) testSubnegotiationStrippedFromText
{
  uint8_t bytes[13] = {'a', 'b', J3TelnetInterpretAsCommand, J3TelnetDo, J3TelnetOptionTerminalType, J3TelnetInterpretAsCommand, J3TelnetBeginSubnegotiation, J3TelnetOptionTerminalType, J3TelnetTerminalTypeSend, J3TelnetInterpretAsCommand, J3TelnetEndSubnegotiation, 'c', 'd'};
  
  NSData *parsedData = [protocolHandler parseData: [NSData dataWithBytes: bytes length: 13]];
  
  uint8_t expectedBytes[4] = {'a', 'b', 'c', 'd'};
  [self assert: parsedData equals: [NSData dataWithBytes: expectedBytes length: 4]];
}

- (void) testParseCRWithSomeTelnetThrownIn
{
  uint8_t bytes[4] = {'\r', J3TelnetInterpretAsCommand, J3TelnetNoOperation, 0};
  NSData *parsedData = [protocolHandler parseData: [NSData dataWithBytes: bytes length: 4]];
  [self assertData: parsedData hasBytesWithZeroTerminator: "\r"];
}

- (void) testParseCRIACIAC
{
  uint8_t bytes[4] = {'\r', J3TelnetInterpretAsCommand, J3TelnetInterpretAsCommand, 0};
  NSData *parsedData = [self parseCString: (const char *) bytes];
  [self assertData: parsedData hasBytesWithZeroTerminator: (const char *) bytes + 2];
}

- (void) testParseLFCRNUL
{
  NSData *parsedData = [protocolHandler parseData: [NSData dataWithBytes: "\n\r\0" length: 3]];
  [self assertData: parsedData hasBytesWithZeroTerminator: "\n\r"];
}

- (void) testParseLFCRLFCR
{
  NSData *parsedData = [self parseCString: "\n\r\n\r"];
  [self assertData: parsedData hasBytesWithZeroTerminator: "\n\n"];
}

- (void) testParseCRCRLF
{
  NSData *parsedData = [self parseCString: "\r\r\n"];
  [self assertData: parsedData hasBytesWithZeroTerminator: "\n"];
}

- (void) testParseCRCRNUL
{
  NSData *parsedData = [protocolHandler parseData: [NSData dataWithBytes: "\r\r\0" length: 3]];
  [self assertData: parsedData hasBytesWithZeroTerminator: "\r"];
}

#pragma mark -
#pragma mark Telnet options

- (void) testDoSuppressGoAhead
{
  [self simulateDo: J3TelnetOptionSuppressGoAhead];
  [self assertTrue: [protocolHandler optionYesForUs: J3TelnetOptionSuppressGoAhead]];
}

- (void) testWillSuppressGoAhead
{
  [self simulateWill: J3TelnetOptionSuppressGoAhead];
  [self assertTrue: [protocolHandler optionYesForHim: J3TelnetOptionSuppressGoAhead]];
}

- (void) testGoAhead
{
  [self confirmTelnetWithDontEcho];
  
  NSData *preprocessedData = [protocolHandler preprocessOutput: [NSData data]];
  
  const char bytes[] = {J3TelnetInterpretAsCommand, J3TelnetGoAhead, 0};
  [self assertData: preprocessedData hasBytesWithZeroTerminator: bytes];
}

- (void) testSuppressedGoAhead
{
  [protocolHandler enableOptionForUs: J3TelnetOptionSuppressGoAhead];
  [self simulateDo: J3TelnetOptionSuppressGoAhead];
  
  NSData *preprocessedData = [protocolHandler preprocessOutput: [NSData data]];
  [self assertInt: [preprocessedData length] equals: 0];
}

- (void) testDoTerminalType
{
  [self simulateDo: J3TelnetOptionTerminalType];
  [self assertTrue: [protocolHandler optionYesForUs: J3TelnetOptionTerminalType]];
}

- (void) testRefuseWillTerminalType
{
  [self simulateWill: J3TelnetOptionTerminalType];
  [self assertFalse: [protocolHandler optionYesForHim: J3TelnetOptionTerminalType]];
}

- (void) testTerminalType
{
  [self simulateDo: J3TelnetOptionTerminalType];
  
  const uint8_t terminalTypeRequest[2] = {J3TelnetOptionTerminalType, J3TelnetTerminalTypeSend};
  
  const uint8_t koanReply[10] = {J3TelnetInterpretAsCommand, J3TelnetBeginSubnegotiation, J3TelnetOptionTerminalType, J3TelnetTerminalTypeIs, 'K', 'O', 'A', 'N', J3TelnetInterpretAsCommand, J3TelnetEndSubnegotiation};
  
  const uint8_t unknownReply[13] = {J3TelnetInterpretAsCommand, J3TelnetBeginSubnegotiation, J3TelnetOptionTerminalType, J3TelnetTerminalTypeIs, 'U', 'N', 'K', 'N', 'O', 'W', 'N', J3TelnetInterpretAsCommand, J3TelnetEndSubnegotiation};
  
  [mockSocketData setData: [NSData data]];
  [self simulateIncomingSubnegotation: terminalTypeRequest length: 2];
  [self assert: mockSocketData equals: [NSData dataWithBytes: koanReply length: 10]];
  
  [mockSocketData setData: [NSData data]];
  [self simulateIncomingSubnegotation: terminalTypeRequest length: 2];
  [self assert: mockSocketData equals: [NSData dataWithBytes: unknownReply length: 13]];
  
  [mockSocketData setData: [NSData data]];
  [self simulateIncomingSubnegotation: terminalTypeRequest length: 2];
  [self assert: mockSocketData equals: [NSData dataWithBytes: unknownReply length: 13]];
  
  [mockSocketData setData: [NSData data]];
  [self simulateIncomingSubnegotation: terminalTypeRequest length: 2];
  [self assert: mockSocketData equals: [NSData dataWithBytes: koanReply length: 10]];
}

- (void) testDoCharset
{
  [self simulateDo: J3TelnetOptionCharset];
  [self assertTrue: [protocolHandler optionYesForUs: J3TelnetOptionCharset]];
}

- (void) testWillCharset
{
  [self simulateWill: J3TelnetOptionCharset];
  [self assertTrue: [protocolHandler optionYesForHim: J3TelnetOptionCharset]];
}

- (void) testCharsetUTF8Accepted
{
  [self simulateWill: J3TelnetOptionTransmitBinary];
  [self simulateDo: J3TelnetOptionTransmitBinary];
  [self simulateWill: J3TelnetOptionCharset];
  
  [self assertInt: protocolHandler.connectionState.stringEncoding equals: NSASCIIStringEncoding];
  
  const uint8_t charsetRequest[8] = {J3TelnetOptionCharset, J3TelnetCharsetRequest, ';', 'U', 'T', 'F', '-', '8'};
  const uint8_t charsetReply[11] = {J3TelnetInterpretAsCommand, J3TelnetBeginSubnegotiation, J3TelnetOptionCharset, J3TelnetCharsetAccepted, 'U', 'T', 'F', '-', '8', J3TelnetInterpretAsCommand, J3TelnetEndSubnegotiation};
  
  [mockSocketData setData: [NSData data]];
  [self simulateIncomingSubnegotation: charsetRequest length: 8];
  [self assert: mockSocketData equals: [NSData dataWithBytes: charsetReply length: 11]];
  
  [self assertInt: protocolHandler.connectionState.stringEncoding equals: NSUTF8StringEncoding];
}

- (void) testCharsetLatin1Accepted
{
  [self simulateWill: J3TelnetOptionTransmitBinary];
  [self simulateDo: J3TelnetOptionTransmitBinary];
  [self simulateWill: J3TelnetOptionCharset];
  
  [self assertInt: protocolHandler.connectionState.stringEncoding equals: NSASCIIStringEncoding];
  
  const uint8_t charsetRequest[13] = {J3TelnetOptionCharset, J3TelnetCharsetRequest, ';', 'I', 'S', 'O', '-', '8', '8', '5', '9', '-', '1'};
  const uint8_t charsetReply[16] = {J3TelnetInterpretAsCommand, J3TelnetBeginSubnegotiation, J3TelnetOptionCharset, J3TelnetCharsetAccepted, 'I', 'S', 'O', '-', '8', '8', '5', '9', '-', '1', J3TelnetInterpretAsCommand, J3TelnetEndSubnegotiation};
  
  [mockSocketData setData: [NSData data]];
  [self simulateIncomingSubnegotation: charsetRequest length: 13];
  [self assert: mockSocketData equals: [NSData dataWithBytes: charsetReply length: 16]];
  
  [self assertInt: protocolHandler.connectionState.stringEncoding equals: NSISOLatin1StringEncoding];
}

- (void) testCharsetRejected
{
  [self simulateWill: J3TelnetOptionTransmitBinary];
  [self simulateDo: J3TelnetOptionTransmitBinary];
  [self simulateWill: J3TelnetOptionCharset];
  
  [self assertInt: protocolHandler.connectionState.stringEncoding equals: NSASCIIStringEncoding];
  
  const uint8_t charsetRequest[10] = {J3TelnetOptionCharset, J3TelnetCharsetRequest, ';', 'I', 'N', 'V', 'A', 'L', 'I', 'D'};
  const uint8_t charsetReply[6] = {J3TelnetInterpretAsCommand, J3TelnetBeginSubnegotiation, J3TelnetOptionCharset, J3TelnetCharsetRejected, J3TelnetInterpretAsCommand, J3TelnetEndSubnegotiation};
  
  [mockSocketData setData: [NSData data]];
  [self simulateIncomingSubnegotation: charsetRequest length: 10];
  [self assert: mockSocketData equals: [NSData dataWithBytes: charsetReply length: 6]];
  
  [self assertInt: protocolHandler.connectionState.stringEncoding equals: NSASCIIStringEncoding];
}

- (void) testCharsetNonStandardBehavior
{
  [self simulateDo: J3TelnetOptionCharset];
  
  [self assertInt: protocolHandler.connectionState.stringEncoding equals: NSASCIIStringEncoding];
  
  const uint8_t charsetRequest[8] = {J3TelnetOptionCharset, J3TelnetCharsetRequest, ';', 'U', 'T', 'F', '-', '8'};
  const uint8_t charsetReply[17] = {J3TelnetInterpretAsCommand, J3TelnetBeginSubnegotiation, J3TelnetOptionCharset, J3TelnetCharsetAccepted, 'U', 'T', 'F', '-', '8', J3TelnetInterpretAsCommand, J3TelnetEndSubnegotiation, J3TelnetInterpretAsCommand, J3TelnetWill, J3TelnetOptionTransmitBinary, J3TelnetInterpretAsCommand, J3TelnetDo, J3TelnetOptionTransmitBinary};
  
  [mockSocketData setData: [NSData data]];
  [self simulateIncomingSubnegotation: charsetRequest length: 8];
  [self assert: mockSocketData equals: [NSData dataWithBytes: charsetReply length: 17]];
  
  [self assertInt: protocolHandler.connectionState.stringEncoding equals: NSUTF8StringEncoding];
}

- (void) testDoEndOfRecord
{
  [self simulateDo: J3TelnetOptionEndOfRecord];
  [self assertTrue: [protocolHandler optionYesForUs: J3TelnetOptionEndOfRecord]];
}

- (void) testWillEndOfRecord
{
  [self simulateWill: J3TelnetOptionEndOfRecord];
  [self assertTrue: [protocolHandler optionYesForHim: J3TelnetOptionEndOfRecord]];
}

- (void) testEndOfRecord
{
  [self simulateDo: J3TelnetOptionSuppressGoAhead];
  
  NSData *preprocessedData = [protocolHandler preprocessOutput: [NSData data]];
  [self assertInt: [preprocessedData length] equals: 0];
  
  [self simulateDo: J3TelnetOptionEndOfRecord];
  
  preprocessedData = [protocolHandler preprocessOutput: [NSData data]];
  
  uint8_t expectedBytes[2] = {J3TelnetInterpretAsCommand, J3TelnetEndOfRecord};
  [self assert: preprocessedData equals: [NSData dataWithBytes: expectedBytes length: 2]];
}

#pragma mark -
#pragma mark J3TelnetProtocolHandlerDelegate Protocol

- (void) log: (NSString *) message arguments: (va_list) args
{
  return;
}

- (void) writeDataToSocket: (NSData *) data
{
  [mockSocketData appendData: data];
}

@end

#pragma mark -

@implementation J3TelnetProtocolHandlerTests (Private)

- (void) assertData: (NSData *) data hasBytesWithZeroTerminator: (const char *) bytes
{
  [self assert: data equals: [NSData dataWithBytes: bytes length: strlen (bytes)]];
}

- (void) confirmTelnetWithDontEcho
{
  uint8_t bytes[3] = {J3TelnetInterpretAsCommand, J3TelnetDont, J3TelnetOptionEcho};
  [protocolHandler parseData: [NSData dataWithBytes: bytes length: 3]];
}

- (NSData *) parseBytesWithZeroTerminator: (const uint8_t *) bytes
{
  return [protocolHandler parseData: [NSData dataWithBytes: bytes length: strlen ((const char *) bytes)]];
}

- (NSData *) parseCString: (const char *) string
{
  return [self parseBytesWithZeroTerminator: (const uint8_t *) string];
}

- (void) resetProtocolHandler
{
  if (protocolHandler)
    [protocolHandler release];
  protocolHandler = [[J3TelnetProtocolHandler protocolHandlerWithConnectionState: [J3TelnetConnectionState connectionState]] retain];
  [protocolHandler setDelegate: self];
}

- (void) simulateDo: (uint8_t) option
{
  const uint8_t doRequest[] = {J3TelnetInterpretAsCommand, J3TelnetDo, option};
  [protocolHandler parseData: [NSData dataWithBytes: doRequest length: 3]];
}

- (void) simulateIncomingSubnegotation: (const uint8_t *) payload length: (unsigned) payloadLength
{
  const uint8_t header[] = {J3TelnetInterpretAsCommand, J3TelnetBeginSubnegotiation};
  const uint8_t footer[] = {J3TelnetInterpretAsCommand, J3TelnetEndSubnegotiation};
  NSMutableData *data = [NSMutableData data];
  [data appendBytes: header length: 2];
  [data appendBytes: payload length: payloadLength];
  [data appendBytes: footer length: 2];
  [protocolHandler parseData: data];
}

- (void) simulateWill: (uint8_t) option
{
  const uint8_t willRequest[] = {J3TelnetInterpretAsCommand, J3TelnetWill, option};
  [protocolHandler parseData: [NSData dataWithBytes: willRequest length: 3]];
}

@end

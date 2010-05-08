//
// J3TelnetEngineTests.m
//
// Copyright (c) 2010 3James Software.
//

#import "J3TelnetEngineTests.h"
#import "J3TelnetConstants.h"

@interface J3TelnetEngineTests (Private)

- (void) assertReadBufferHasBytesWithZeroTerminator: (const uint8_t *) bytes;
- (void) assertReadBufferHasCString: (const char *) string;
- (void) assertOutputBufferHasBytesWithZeroTerminator: (const uint8_t *) bytes;
- (void) clearReadBuffer;
- (void) clearOutputBuffer;
- (void) parseBytesWithZeroTerminator: (const uint8_t *) bytes;
- (void) parseCString: (const char *) string;
- (void) resetEngine;
- (void) simulateDo: (uint8_t) option;
- (void) simulateSubnegotation: (const uint8_t *) payload length: (unsigned) payloadLength;
- (void) simulateWill: (uint8_t) option;

@end

#pragma mark -

@implementation J3TelnetEngineTests

- (void) setUp
{
  [self resetEngine];
  [engine confirmTelnet];
  readBuffer = [[NSMutableData alloc] init];
  outputBuffer = [[NSMutableData alloc] init];
  dataSegments = [[NSMutableArray alloc] init];
}

- (void) tearDown
{
  [engine release];
  [readBuffer release];
  [outputBuffer release];
  [dataSegments release];
}

- (void) testGoAhead
{
  [engine goAhead];
  const uint8_t bytes[] = {J3TelnetInterpretAsCommand, J3TelnetGoAhead, 0};
  [self assertOutputBufferHasBytesWithZeroTerminator: bytes];
}

- (void) testIACEscapedInData
{
  uint8_t bytes[] = {J3TelnetInterpretAsCommand};
  NSData *data = [NSData dataWithBytes: bytes length: 1];
  [outputBuffer setData: [engine preprocessOutput: data]];
  const uint8_t expected[] = {J3TelnetInterpretAsCommand, J3TelnetInterpretAsCommand, 0};
  [self assertOutputBufferHasBytesWithZeroTerminator: expected];
}

- (void) testConfirmTelnet
{
  [self resetEngine];
  [self assertFalse: [engine telnetConfirmed] message: @"before confirmation"];
  [engine confirmTelnet];
  [self assertTrue: [engine telnetConfirmed] message: @"after confirmation"];
  [engine confirmTelnet];
  [self assertTrue: [engine telnetConfirmed] message: @"after re-confirmation"];
}

- (void) testTelnetNotSentWhenNotConfirmed
{
  [self resetEngine];
  [engine goAhead];
  [engine endOfRecord];
  [engine enableOptionForUs: 0];
  [engine enableOptionForHim: 0];
  [engine disableOptionForUs: 0];
  [engine disableOptionForHim: 0];
  [self assert: outputBuffer equals: [NSData data] message: @"telnet was written"];
}

- (void) testParsePlainText
{
  [self parseCString: "foo"];
  [self assertReadBufferHasCString: "foo"];
}

- (void) testParseLF
{
  [self parseCString: "\n"];
  [self assertReadBufferHasCString: "\n"];
}

- (void) testParseCRLF
{
  [self parseCString: "\r\n"];
  [self assertReadBufferHasCString: "\n"];
}

- (void) testParseCRNUL
{
  [engine parseData: [NSData dataWithBytes: "\r\0" length: 2]];
  [self assertReadBufferHasCString: "\r"];
}

- (void) testParseCRSomethingElse
{
  uint8_t bytes[2] = {'\r', 0};
  
  for (unsigned i = 1; i < UINT8_MAX; i++)
  {
    if (i == '\n' || i == '\r')
      continue;
    bytes[1] = i;
    [self clearReadBuffer];
    [engine parseData: [NSData dataWithBytes: bytes length: 2]];
    [self assert: readBuffer equals: [NSData dataWithBytes: bytes + 1 length: 1]];
  }
}

- (void) testSubnegotiationPutsPayloadInReadBuffer
{
  uint8_t bytes[4] = {J3TelnetInterpretAsCommand, J3TelnetBeginSubnegotiation, J3TelnetOptionTerminalType, J3TelnetTerminalTypeSend}; // Incomplete on purpose.
  
  [engine parseData: [NSData dataWithBytes: bytes length: 4]];
  
  uint8_t expectedBytes[2] = {J3TelnetOptionTerminalType, 1};
  [self assert: readBuffer equals: [NSData dataWithBytes: expectedBytes length: 2]];
}

- (void) testBeginSubnegotiationClearsExistingDataInReadBuffer
{
  uint8_t bytes[6] = {'a', 'b', J3TelnetInterpretAsCommand, J3TelnetBeginSubnegotiation, J3TelnetOptionTerminalType, J3TelnetTerminalTypeSend}; // Incomplete on purpose.
  
  [engine parseData: [NSData dataWithBytes: bytes length: 6]];
  
  uint8_t expectedBytes[2] = {J3TelnetOptionTerminalType, 1};
  [self assert: readBuffer equals: [NSData dataWithBytes: expectedBytes length: 2]];
}

- (void) testEndSubnegotiationClearsSubnegotiationPayloadFromReadBuffer
{
  uint8_t bytes[8] = {J3TelnetInterpretAsCommand, J3TelnetBeginSubnegotiation, J3TelnetOptionTerminalType, J3TelnetTerminalTypeSend, J3TelnetInterpretAsCommand, J3TelnetEndSubnegotiation, 'c', 'd'};
  
  [engine parseData: [NSData dataWithBytes: bytes length: 8]];
  [self assertReadBufferHasCString: "cd"];
}

- (void) testSubnegotiationDataSegments
{
  uint8_t bytes[10] = {'a', 'b', J3TelnetInterpretAsCommand, J3TelnetBeginSubnegotiation, J3TelnetOptionTerminalType, J3TelnetTerminalTypeSend, J3TelnetInterpretAsCommand, J3TelnetEndSubnegotiation, 'c', 'd'};
  
  [engine parseData: [NSData dataWithBytes: bytes length: 10]];
  [self consumeReadBufferAsText];
  
  [self assertTrue: [dataSegments count] == 3];
  
  id segmentOne = [dataSegments objectAtIndex: 0];
  [self assertTrue: [segmentOne isKindOfClass: [NSString class]]];
  [self assert: segmentOne equals: @"ab"];
  
  id segmentTwo = [dataSegments objectAtIndex: 1];
  [self assertTrue: [segmentTwo isKindOfClass: [NSData class]]];
  
  uint8_t expectedBytes[2] = {J3TelnetOptionTerminalType, 1};
  [self assert: segmentTwo equals: [NSData dataWithBytes: expectedBytes length: 2]];
  
  id segmentThree = [dataSegments objectAtIndex: 2];
  [self assertTrue: [segmentThree isKindOfClass: [NSString class]]];
  [self assert: segmentThree equals: @"cd"];
}

- (void) testParseCRWithSomeTelnetThrownIn
{
  uint8_t bytes[4] = {'\r', J3TelnetInterpretAsCommand, J3TelnetNoOperation, 0};
  [engine parseData: [NSData dataWithBytes: bytes length: 4]];
  [self assertReadBufferHasCString: "\r"];
}

- (void) testParseCRIACIAC
{
  uint8_t bytes[4] = {'\r', J3TelnetInterpretAsCommand, J3TelnetInterpretAsCommand, 0};
  [self parseCString: (const char *) bytes];
  [self assertReadBufferHasCString: (const char *) bytes + 2];
}

- (void) testParseLFCRNUL
{
  [engine parseData: [NSData dataWithBytes: "\n\r\0" length: 3]];
  [self assertReadBufferHasCString: "\n\r"];
}

- (void) testParseLFCRLFCR
{
  [self parseCString: "\n\r\n\r"];
  [self assertReadBufferHasCString: "\n\n"];
}

- (void) testParseCRCRLF
{
  [self parseCString: "\r\r\n"];
  [self assertReadBufferHasCString: "\n"];
}

- (void) testParseCRCRNUL
{
  [engine parseData: [NSData dataWithBytes: "\r\r\0" length: 3]];
  [self assertReadBufferHasCString: "\r"];
}

#pragma mark -
#pragma mark Telnet options

- (void) testDoSuppressGoAhead
{
  [self simulateDo: J3TelnetOptionSuppressGoAhead];
  [self assertTrue: [engine optionYesForUs: J3TelnetOptionSuppressGoAhead]];
}

- (void) testWillSuppressGoAhead
{
  [self simulateWill: J3TelnetOptionSuppressGoAhead];
  [self assertTrue: [engine optionYesForHim: J3TelnetOptionSuppressGoAhead]];
}

- (void) testSuppressGoAhead
{
  [engine enableOptionForUs: J3TelnetOptionSuppressGoAhead];
  [self clearOutputBuffer];
  [self simulateDo: J3TelnetOptionSuppressGoAhead];
  [engine goAhead];
  [self assertInt: [outputBuffer length] equals: 0];
}

- (void) testDoTerminalType
{
  [self simulateDo: J3TelnetOptionTerminalType];
  [self assertTrue: [engine optionYesForUs: J3TelnetOptionTerminalType]];
}

- (void) testRefuseWillTerminalType
{
  [self simulateWill: J3TelnetOptionTerminalType];
  [self assertFalse: [engine optionYesForHim: J3TelnetOptionTerminalType]];
}

- (void) testTerminalType
{
  [self simulateDo: J3TelnetOptionTerminalType];
  
  const uint8_t requestTerminalType[2] = {J3TelnetOptionTerminalType, J3TelnetTerminalTypeSend};
  
  const uint8_t koanReply[10] = {J3TelnetInterpretAsCommand, J3TelnetBeginSubnegotiation, J3TelnetOptionTerminalType, 0, 'K', 'O', 'A', 'N', J3TelnetInterpretAsCommand, J3TelnetEndSubnegotiation};
  
  const uint8_t unknownReply[13] = {J3TelnetInterpretAsCommand, J3TelnetBeginSubnegotiation, J3TelnetOptionTerminalType, 0, 'U', 'N', 'K', 'N', 'O', 'W', 'N', J3TelnetInterpretAsCommand, J3TelnetEndSubnegotiation};
  
  [self clearOutputBuffer];
  [self simulateSubnegotation: requestTerminalType length: 2];
  [self assert: outputBuffer equals: [NSData dataWithBytes: koanReply length: 10]];
  
  [self clearOutputBuffer];
  [self simulateSubnegotation: requestTerminalType length: 2];
  [self assert: outputBuffer equals: [NSData dataWithBytes: unknownReply length: 13]];
  
  [self clearOutputBuffer];
  [self simulateSubnegotation: requestTerminalType length: 2];
  [self assert: outputBuffer equals: [NSData dataWithBytes: unknownReply length: 13]];
  
  [self clearOutputBuffer];
  [self simulateSubnegotation: requestTerminalType length: 2];
  [self assert: outputBuffer equals: [NSData dataWithBytes: koanReply length: 10]];
}

- (void) testDoCharset
{
  [self simulateDo: J3TelnetOptionCharset];
  [self assertTrue: [engine optionYesForUs: J3TelnetOptionCharset]];
}

- (void) testWillCharset
{
  [self simulateWill: J3TelnetOptionCharset];
  [self assertTrue: [engine optionYesForHim: J3TelnetOptionCharset]];
}

- (void) testCharset
{
  [self simulateDo: J3TelnetOptionTerminalType];
  
  const uint8_t requestTerminalType[2] = {J3TelnetOptionTerminalType, J3TelnetTerminalTypeSend};
  
  const uint8_t koanReply[10] = {J3TelnetInterpretAsCommand, J3TelnetBeginSubnegotiation, J3TelnetOptionTerminalType, 0, 'K', 'O', 'A', 'N', J3TelnetInterpretAsCommand, J3TelnetEndSubnegotiation};
  
  const uint8_t unknownReply[13] = {J3TelnetInterpretAsCommand, J3TelnetBeginSubnegotiation, J3TelnetOptionTerminalType, 0, 'U', 'N', 'K', 'N', 'O', 'W', 'N', J3TelnetInterpretAsCommand, J3TelnetEndSubnegotiation};
  
  [self clearOutputBuffer];
  [self simulateSubnegotation: requestTerminalType length: 2];
  [self assert: outputBuffer equals: [NSData dataWithBytes: koanReply length: 10]];
  
  [self clearOutputBuffer];
  [self simulateSubnegotation: requestTerminalType length: 2];
  [self assert: outputBuffer equals: [NSData dataWithBytes: unknownReply length: 13]];
  
  [self clearOutputBuffer];
  [self simulateSubnegotation: requestTerminalType length: 2];
  [self assert: outputBuffer equals: [NSData dataWithBytes: unknownReply length: 13]];
  
  [self clearOutputBuffer];
  [self simulateSubnegotation: requestTerminalType length: 2];
  [self assert: outputBuffer equals: [NSData dataWithBytes: koanReply length: 10]];
}

- (void) testDoEndOfRecord
{
  [self simulateDo: J3TelnetOptionEndOfRecord];
  [self assertTrue: [engine optionYesForUs: J3TelnetOptionEndOfRecord]];
}

- (void) testWillEndOfRecord
{
  [self simulateWill: J3TelnetOptionEndOfRecord];
  [self assertTrue: [engine optionYesForHim: J3TelnetOptionEndOfRecord]];
}

- (void) testEndOfRecordOff
{
  [engine endOfRecord];
  [self assertInt: [outputBuffer length] equals: 0];
}

#pragma mark -
#pragma mark J3TelnetEngineDelegate Protocol

- (void) bufferInputByte: (uint8_t) byte
{
  [readBuffer appendBytes: &byte length: 1];
}

- (void) consumeReadBufferAsSubnegotiation
{
  [dataSegments addObject: [NSData dataWithData: readBuffer]];
  [engine handleIncomingSubnegotiation: readBuffer];
  [readBuffer setData: [NSMutableData data]];
}

- (void) consumeReadBufferAsText
{
  [dataSegments addObject: [[[NSString alloc] initWithData: readBuffer encoding: NSASCIIStringEncoding] autorelease]];
  [readBuffer setData: [NSMutableData data]];
}

- (void) log: (NSString *) message arguments: (va_list) args
{
  return;
}

- (void) writeData: (NSData *) data
{
  [outputBuffer appendData: data];
}

@end

#pragma mark -

@implementation J3TelnetEngineTests (Private)

- (void) assertReadBufferHasBytesWithZeroTerminator: (const uint8_t *) bytes
{
  [self assert: readBuffer equals: [NSData dataWithBytes: bytes length: strlen ((const char *) bytes)]];
}

- (void) assertReadBufferHasCString: (const char *) string
{
  [self assertReadBufferHasBytesWithZeroTerminator: (const uint8_t *) string];
}

- (void) assertOutputBufferHasBytesWithZeroTerminator: (const uint8_t *) bytes
{
  [self assert: outputBuffer equals: [NSData dataWithBytes: bytes length: strlen ((const char *) bytes)]];
}

- (void) clearReadBuffer
{
  [readBuffer setData: [NSData data]];
}

- (void) clearOutputBuffer
{
  [outputBuffer setData: [NSData data]]; 
}

- (void) parseBytesWithZeroTerminator: (const uint8_t *) bytes
{
  [engine parseData: [NSData dataWithBytes: bytes length: strlen ((const char *) bytes)]];
}

- (void) parseCString: (const char *) string
{
  [self parseBytesWithZeroTerminator: (const uint8_t *) string];
}

- (void) resetEngine
{
  [self at: &engine put: [J3TelnetEngine engine]];
  [engine setDelegate: self];  
}

- (void) simulateDo: (uint8_t) option
{
  const uint8_t doRequest[] = {J3TelnetInterpretAsCommand, J3TelnetDo, option};
  [engine parseData: [NSData dataWithBytes: doRequest length: 3]];
}

- (void) simulateSubnegotation: (const uint8_t *) payload length: (unsigned) payloadLength
{
  const uint8_t header[] = {J3TelnetInterpretAsCommand, J3TelnetBeginSubnegotiation};
  const uint8_t footer[] = {J3TelnetInterpretAsCommand, J3TelnetEndSubnegotiation};
  NSMutableData *data = [NSMutableData data];
  [data appendBytes: header length: 2];
  [data appendBytes: payload length: payloadLength];
  [data appendBytes: footer length: 2];
  [engine parseData: data];
}

- (void) simulateWill: (uint8_t) option
{
  const uint8_t willRequest[] = {J3TelnetInterpretAsCommand, J3TelnetWill, option};
  [engine parseData: [NSData dataWithBytes: willRequest length: 3]];
}

@end

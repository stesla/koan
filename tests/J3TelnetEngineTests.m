//
//  J3TelnetEngineTests.m
//  Koan
//
//  Created by Samuel Tesla on 4/5/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "J3TelnetEngineTests.h"
#import "J3TelnetConstants.h"

@interface J3TelnetEngineTests (Private)

- (void) assertInputBufferHasBytesWithZeroTerminator: (const uint8_t *) bytes;
- (void) assertInputBufferHasCString: (const char *) string;
- (void) assertOutputBufferHasBytesWithZeroTerminator: (const uint8_t *) bytes;
- (void) clearInputBuffer;
- (void) clearOutputBuffer;
- (void) parseBytesWithZeroTerminator: (const uint8_t *) bytes;
- (void) parseCString: (const char *) string;
- (void) resetEngine;
- (void) simulateDo: (uint8_t) option;
- (void) simulateWill: (uint8_t) option;

@end

@implementation J3TelnetEngineTests

- (void) setUp
{
  [self resetEngine];
  [engine confirmTelnet];
  [self at: &inputBuffer put: [NSMutableData data]];
  [self at: &outputBuffer put: [NSMutableData data]]; 
}

- (void) tearDown
{
  [engine release];
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

- (void) testEndOfRecordOn
{
  [self simulateDo: J3TelnetOptionEndOfRecord];
  [self clearOutputBuffer];
  [engine endOfRecord];
  const uint8_t bytes[] = {J3TelnetInterpretAsCommand, J3TelnetEndOfRecord, 0};
  [self assertOutputBufferHasBytesWithZeroTerminator: bytes];
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
  [self assertInputBufferHasCString: "foo"];
}

- (void) testParseLF
{
  [self parseCString: "\n"];
  [self assertInputBufferHasCString: "\n"];
}

- (void) testParseCRLF
{
  [self parseCString: "\r\n"];
  [self assertInputBufferHasCString: "\n"];
}

- (void) testParseCRNUL
{
  [engine parseData: [NSData dataWithBytes: "\r\0" length: 2]];
  [self assertInputBufferHasCString: "\r"];
}

- (void) testCRSomethingElse
{
  uint8_t bytes[2] = {'\r', 0};
  for (unsigned i = 1; i < UINT8_MAX; ++i)
  {
    if (i == '\n' || i == '\r')
      continue;
    bytes[1] = i;
    [self clearInputBuffer];
    [engine parseData: [NSData dataWithBytes: bytes length: 2]];
    [self assert: inputBuffer equals: [NSData dataWithBytes: bytes + 1 length: 1]];
  }
}

- (void) testCRWithSomeTelnetThrownIn
{
  uint8_t bytes[4] = {'\r', J3TelnetInterpretAsCommand, J3TelnetNoOperation, 0};
  [engine parseData: [NSData dataWithBytes: bytes length: 4]];
  [self assertInputBufferHasCString: "\r"];
}

- (void) testCRIACIAC
{
  uint8_t bytes[4] = {'\r', J3TelnetInterpretAsCommand, J3TelnetInterpretAsCommand, 0};
  [self parseCString: (const char *) bytes];
  [self assertInputBufferHasCString: (const char *) bytes + 2];
}

- (void) testLFCRNUL
{
  [engine parseData: [NSData dataWithBytes: "\n\r\0" length: 3]];
  [self assertInputBufferHasCString: "\n\r"];
}

- (void) testLFCRLFCR
{
  [self parseCString: "\n\r\n\r"];
  [self assertInputBufferHasCString: "\n\n"];
}

- (void) testCRCRLF
{
  [self parseCString: "\r\r\n"];
  [self assertInputBufferHasCString: "\n"];
}

- (void) testCRCRNUL
{
  [engine parseData: [NSData dataWithBytes: "\r\r\0" length: 3]];
  [self assertInputBufferHasCString: "\r"];
}

#pragma mark -
#pragma mark J3TelnetEngineDelegate Protocol

- (void) bufferInputByte: (uint8_t) byte
{
  [inputBuffer appendBytes: &byte length: 1];
}

- (void) log: (NSString *) message arguments: (va_list) args
{
}

- (void) writeData: (NSData *) data
{
  [outputBuffer appendData: data];
}

@end

@implementation J3TelnetEngineTests (Private)

- (void) assertInputBufferHasBytesWithZeroTerminator: (const uint8_t *) bytes
{
  [self assert: inputBuffer equals: [NSData dataWithBytes: bytes length: strlen ((const char *) bytes)]];
}

- (void) assertInputBufferHasCString: (const char *) string
{
  [self assertInputBufferHasBytesWithZeroTerminator: (const uint8_t *) string];
}

- (void) assertOutputBufferHasBytesWithZeroTerminator: (const uint8_t *) bytes
{
  [self assert: outputBuffer equals: [NSData dataWithBytes: bytes length: strlen ((const char *) bytes)]];
}

- (void) clearInputBuffer
{
  [inputBuffer setData: [NSData data]];
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

- (void) simulateWill: (uint8_t) option
{
  const uint8_t doRequest[] = {J3TelnetInterpretAsCommand, J3TelnetWill, option};
  [engine parseData: [NSData dataWithBytes: doRequest length: 3]];
}

@end

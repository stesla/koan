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

- (void) assertBufferHasBytesWithZeroTerminator: (const uint8_t *) bytes;
- (void) clearBuffer;
- (void) resetEngine;
- (void) simulateDo: (uint8_t) option;
- (void) simulateWill: (uint8_t) option;

@end

@implementation J3TelnetEngineTests

- (void) setUp
{
  [self resetEngine];
  [engine confirmTelnet];
  [self at: &buffer put: [NSMutableData data]]; 
}

- (void) tearDown
{
  [engine release];
}

- (void) testGoAhead
{
  [engine goAhead];
  const uint8_t bytes[] = {J3TelnetInterpretAsCommand, J3TelnetGoAhead, 0};
  [self assertBufferHasBytesWithZeroTerminator: bytes];
}

- (void) testIACEscapedInData
{
  uint8_t bytes[] = {J3TelnetInterpretAsCommand};
  NSData *data = [NSData dataWithBytes: bytes length: 1];
  [buffer setData: [engine preprocessOutput: data]];
  const uint8_t expected[] = {J3TelnetInterpretAsCommand, J3TelnetInterpretAsCommand, 0};
  [self assertBufferHasBytesWithZeroTerminator: expected];
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
  [self clearBuffer];
  [self simulateDo: J3TelnetOptionSuppressGoAhead];
  [engine goAhead];
  [self assertInt: [buffer length] equals: 0];
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
  [self assertInt: [buffer length] equals: 0];
}

- (void) testEndOfRecordOn
{
  [self simulateDo: J3TelnetOptionEndOfRecord];
  [self clearBuffer];
  [engine endOfRecord];
  const uint8_t bytes[] = {J3TelnetInterpretAsCommand, J3TelnetEndOfRecord, 0};
  [self assertBufferHasBytesWithZeroTerminator: bytes];
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
  [self assert: buffer equals: [NSData data] message: @"telnet was written"];
}

#pragma mark -
#pragma mark J3TelnetEngineDelegate Protocol

- (void) bufferInputByte: (uint8_t) byte
{
}

- (void) log: (NSString *) message arguments: (va_list) args
{
}

- (void) writeData: (NSData *) data
{
  [buffer appendData: data];
}

@end

@implementation J3TelnetEngineTests (Private)

- (void) assertBufferHasBytesWithZeroTerminator: (const uint8_t *) bytes
{
  [self assert: buffer equals: [NSData dataWithBytes: bytes length: strlen((const char *) bytes)]];
}

- (void) clearBuffer
{
  [buffer setData: [NSData data]]; 
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

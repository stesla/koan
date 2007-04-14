//
//  J3TelnetEngineTests.m
//  Koan
//
//  Created by Samuel Tesla on 4/5/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "J3TelnetEngineTests.h"
#import "J3TelnetConstants.h"

@implementation J3TelnetEngineTests

- (void) setUp
{
  buffer = [[NSMutableData data] retain];
  engine = [[J3TelnetEngine engine] retain];
  [engine setDelegate: self];
}

- (void) tearDown
{
  [engine release];
}

- (void) testGoAhead
{
  [engine goAhead];
  [self assertInt: [buffer length] equals: 2 message: @"length"];
  [self assertInt: ((uint8_t *) [buffer bytes])[0] equals: J3TelnetInterpretAsCommand message: @"IAC"];
  [self assertInt: ((uint8_t *) [buffer bytes])[1] equals: J3TelnetGoAhead message: @"GA"];
}

- (void) testIACEscapedInData
{
  uint8_t bytes[] = {J3TelnetInterpretAsCommand};
  NSData *data = [NSData dataWithBytes: bytes length: 1];
  
  [buffer setData: [engine preprocessOutput: data]];
  [self assertInt: [buffer length] equals: 2 message: @"length"];
  [self assertInt: ((uint8_t *) [buffer bytes])[0] equals: J3TelnetInterpretAsCommand message: @"IAC1"];
  [self assertInt: ((uint8_t *) [buffer bytes])[0] equals: J3TelnetInterpretAsCommand message: @"IAC2"];  
}

- (void) testNegotiateOptions
{
  [engine negotiateOptions];
  const uint8_t expected[] = {
    J3TelnetInterpretAsCommand, J3TelnetWill, J3TelnetOptionSuppressGoAhead,
    J3TelnetInterpretAsCommand, J3TelnetDo, J3TelnetOptionSuppressGoAhead,
    0};
  [self assertInt: [buffer length] equals: strlen((const char *) expected) message: @"length"];
  for (unsigned i = 0; i < [buffer length]; ++i)
    [self assertInt: ((uint8_t *)[buffer bytes])[i] equals: expected[i]];
}

- (void) testSuppressGoAhead
{
  [engine enableOptionForUs: J3TelnetOptionSuppressGoAhead];
  [buffer setData: [NSData data]];
  const uint8_t response[] = {J3TelnetInterpretAsCommand, J3TelnetDo, J3TelnetOptionSuppressGoAhead};
  [engine parseData: [NSData dataWithBytes: response length: 3]];
  [engine goAhead];
  [self assertInt: [buffer length] equals: 0];
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

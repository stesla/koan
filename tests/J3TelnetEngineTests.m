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
  [self assertInt: ((uint8_t *)[buffer bytes])[0] equals: J3TelnetInterpretAsCommand message: @"IAC"];
  [self assertInt: ((uint8_t *)[buffer bytes])[1] equals: J3TelnetGoAhead message: @"GA"];
}

- (void) testIACEscapedInData
{
  uint8_t bytes[] = {J3TelnetInterpretAsCommand};
  NSData *data = [NSData dataWithBytes: bytes length: 1];
  
  [buffer setData: [engine preprocessOutput: data]];
  [self assertInt: [buffer length] equals: 2 message: @"length"];
  [self assertInt: ((uint8_t *)[buffer bytes])[0] equals: J3TelnetInterpretAsCommand message: @"IAC1"];
  [self assertInt: ((uint8_t *)[buffer bytes])[0] equals: J3TelnetInterpretAsCommand message: @"IAC2"];  
}

#pragma mark -
#pragma mark J3TelnetEngineDelegate Protocol

- (void) bufferInputByte: (uint8_t) byte
{
}

- (void) log: (NSString *) message arguments: (va_list) args
{
}

- (void) writeDataWithPriority: (NSData *) data;
{
  [buffer appendData: data];
}

@end

//
//  J3TelnetParser.m
//  NewTelnet
//
//  Created by Samuel Tesla on 11/9/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "J3TelnetParser.h"
#import "J3TelnetTextState.h"

@implementation J3TelnetParser
+ (id) parser;
{
  return [[[self alloc] init] autorelease];
}

- (id) init
{
  if (![super init])
    return nil;
  state = [J3TelnetTextState state];
  return self;
}

- (void) bufferInputByte:(uint8_t)byte;
{
  [inputBuffer append:byte];
}

- (void) bufferOutputByte:(uint8_t)byte;
{
  [outputBuffer append:byte];
}

- (void) parse:(uint8_t)byte;
{
  state = [state parse:byte forParser:self];
}

- (void) parse:(uint8_t *)bytes count:(int)count;
{
  int i;
  for (i = 0; i < count; i++)
    [self parse:bytes[i]];
}

- (void) setInputBuffer:(id <NSObject, J3Buffer>)buffer;
{
  [buffer retain];
  [inputBuffer release];
  inputBuffer = buffer;
}

- (void) setOuptutBuffer:(id <NSObject, J3Buffer>)buffer;
{
  [buffer retain];
  [outputBuffer release];
  outputBuffer = buffer;
}

@end

//
// J3TelnetParser.m
//
// Copyright (c) 2005, 2006 3James Software
//

#import "J3TelnetConstants.h"
#import "J3TelnetParser.h"
#import "J3TelnetTextState.h"

@interface J3TelnetParser (Private)

- (void) sendCommand:(uint8_t)command withByte:(uint8_t)byte;

@end

@implementation J3TelnetParser

+ (id) parser
{
  return [[[self alloc] init] autorelease];
}

- (id) init
{
  if (![super init])
    return nil;
  state = [[J3TelnetTextState state] retain];
  return self;
}

- (void) bufferInputByte:(uint8_t)byte
{
  [inputBuffer append:byte];
}

- (void) bufferOutputByte:(uint8_t)byte
{
  [outputBuffer append:byte];
}

- (void) dont:(uint8_t)byte;
{
  [self sendCommand:J3TelnetDont withByte:byte];
}

- (BOOL) hasInputBuffer:(id <J3Buffer>)buffer;
{
  return buffer == inputBuffer;
}

- (void) parse:(uint8_t)byte
{
  [self at:&state put:[state parse:byte forParser:self]];
}

- (void) parse:(uint8_t *)bytes length:(int)count
{
  int i;
  for (i = 0; i < count; i++)
    [self parse:bytes[i]];
}

- (void) setInputBuffer:(NSObject <J3Buffer> *)buffer
{
  [buffer retain];
  [inputBuffer release];
  inputBuffer = buffer;
}

- (void) setOuptutBuffer:(NSObject <J3Buffer> *)buffer
{
  [buffer retain];
  [outputBuffer release];
  outputBuffer = buffer;
}

- (void) wont:(uint8_t)byte;
{
  [self sendCommand:J3TelnetWont withByte:byte];
}
@end

@implementation J3TelnetParser (Private)

- (void) sendCommand:(uint8_t)command withByte:(uint8_t)byte;
{
  [self bufferOutputByte:J3TelnetInterpretAsCommand];
  [self bufferOutputByte:command];
  [self bufferOutputByte:byte];
  [outputBuffer flush];  
}

@end


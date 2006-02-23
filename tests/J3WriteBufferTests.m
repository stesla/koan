//
// J3WriteBufferTests.m
//
// Copyright (c) 2005 3James Software
//

#import "J3WriteBufferTests.h"
#import "J3WriteBuffer.h"

@interface J3WriteBufferTests (Private)

- (NSString *) output;
- (void) setLengthWritten:(unsigned)length;
- (void) assertOutputIsString:(NSString *)string;
- (void) assertOutputIsString:(NSString *)string lengthWritten:(unsigned)length;

@end

@implementation J3WriteBufferTests

- (BOOL) hasSpaceAvailable;
{
  return YES;
}

- (void) setUp
{
  buffer = [[J3WriteBuffer buffer] retain];
  [buffer setByteDestination:self];
  output = [[NSMutableData data] retain];
}

- (void) tearDown
{
  [output release];
  [buffer release];
}

- (void) testWriteNil
{
  [buffer appendString:nil];
  [self assertOutputIsString:@""];
}

- (void) testWriteMultipleTimes
{
  [buffer appendString:@"foo"];
  [buffer appendString:@"bar"];
  [self assertOutputIsString:@"foobar"];
}

- (void) testWriteMultipleTimesWithInterspersedNil
{
  [buffer appendString:@"foo"];
  [buffer appendString:nil];
  [buffer appendString:@"bar"];
  [self assertOutputIsString:@"foobar"];
}

- (void) testWriteAll
{
  [buffer appendString:@"foo"];
  [self assertOutputIsString:@"foo"];
}

- (void) testWriteSome
{
  [buffer appendString:@"123456"];
  [self assertOutputIsString:@"123456" lengthWritten:3];
}

- (void) testWriteLine
{
  [buffer appendLine:@"foo"];
  [self assertOutputIsString:@"foo\n"];
}

- (unsigned) write:(const uint8_t *)bytes length:(unsigned)length;
{
  unsigned lengthToWrite = lengthWritten < length ? lengthWritten : length;
  [output appendBytes:bytes length:lengthToWrite];
  return lengthToWrite;
}

@end

#pragma mark -

@implementation J3WriteBufferTests (Private)

- (void) assertOutputIsString:(NSString *)string
{
  [self assertOutputIsString:string lengthWritten:[string length]];
}

- (void) assertOutputIsString:(NSString *)string lengthWritten:(unsigned)length
{
  [self setLengthWritten:length];
  [buffer flush];
  [self assert:[self output] equals:string];
}

- (void) setLengthWritten:(unsigned)length
{
  lengthWritten = length;
}

- (NSString *) output
{
  return [[[NSString alloc] initWithData:output encoding:NSASCIIStringEncoding] autorelease];
}

@end

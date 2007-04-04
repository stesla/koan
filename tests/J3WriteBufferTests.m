//
// J3WriteBufferTests.m
//
// Copyright (c) 2007 3James Software.
//

#import "J3WriteBufferTests.h"
#import "J3WriteBuffer.h"

@interface J3WriteBufferTests (Private)

- (NSString *) output;
- (void) setMaxBytesPerWrite: (unsigned) numberOfBytes;
- (void) assertNumberOfWrites: (unsigned) number;
- (void) assertOutputIsString: (NSString *) string;
- (void) assertOutputIsString: (NSString *) string maxBytesPerFlush: (unsigned) length;

@end

#pragma mark -

@implementation J3WriteBufferTests

- (BOOL) hasSpaceAvailable;
{
  return YES;
}

- (void) setUp
{
  numberOfWrites = 0;
  buffer = [[J3WriteBuffer buffer] retain];
  [buffer setByteDestination: self];
  output = [[NSMutableData data] retain];
}

- (void) tearDown
{
  [output release];
  [buffer release];
}

- (void) testWriteNil
{
  [buffer appendString: nil];
  [self assertOutputIsString: @"" maxBytesPerFlush: 1];
  [self assertNumberOfWrites: 0];
}

- (void) testWriteMultipleTimes
{
  [buffer appendString: @"foo"];
  [buffer appendString: @"bar"];
  [self assertOutputIsString: @"foobar"];
}

- (void) testWriteMultipleTimesWithInterspersedNil
{
  [buffer appendString: @"foo"];
  [buffer appendString: nil];
  [buffer appendString: @"bar"];
  [self assertOutputIsString: @"foobar"];
}

- (void) testClearBufferAndWrite
{
  [buffer appendString: @"foo"];
  [buffer clear];
  [self assertOutputIsString: @"" maxBytesPerFlush: 1];
  [self assertNumberOfWrites: 0];
}

- (void) testClearBufferThenAddMoreAndWrite
{
  [buffer appendString: @"foo"];
  [buffer clear];
  [buffer appendString: @"bar"];
  [self assertOutputIsString: @"bar"];
}

#ifdef TYLER_WILL_FIX
- (void) testRemoveLastCharacterAndWrite
{
  [buffer appendString: @"foop"];
  [buffer removeLastCharacter];
  [self assertOutputIsString: @"foo"];
}
#endif

- (void) testWriteAll
{
  [buffer appendString: @"foo"];
  [self assertOutputIsString: @"foo"];
}

- (void) testWriteSome
{
  [buffer appendString: @"123456"];
  [self assertOutputIsString: @"123456" maxBytesPerFlush: 3];
  [self assertNumberOfWrites: 2];
}

- (void) testWriteLine
{
  [buffer appendLine: @"foo"];
  [self assertOutputIsString: @"foo\n"];
}

#pragma mark -
#pragma mark J3ByteDestination protocol

- (unsigned) write: (NSData *) data
{
  unsigned lengthToWrite = maxBytesPerWrite < [data length] ? maxBytesPerWrite : [data length];
  [output appendBytes: [data bytes] length: lengthToWrite];
  numberOfWrites++;
  return lengthToWrite;
}

@end

#pragma mark -

@implementation J3WriteBufferTests (Private)

- (void) assertNumberOfWrites: (unsigned) number
{
  [self assertInt: (int) numberOfWrites equals: (int) number];
}

- (void) assertOutputIsString: (NSString *) string
{
  [self assertOutputIsString: string maxBytesPerFlush: [string length]];
  [self assertNumberOfWrites: 1];
}

- (void) assertOutputIsString: (NSString *) string maxBytesPerFlush: (unsigned) length
{
  [self setMaxBytesPerWrite: length];
  [buffer flush];
  [self assert: [self output] equals: string];
}

- (void) setMaxBytesPerWrite: (unsigned) numberOfBytes
{
  maxBytesPerWrite = numberOfBytes;
}

- (NSString *) output
{
  return [[[NSString alloc] initWithData: output encoding: NSASCIIStringEncoding] autorelease];
}

@end

//
// J3WriteBufferTests.m
//
// Copyright (c) 2007 3James Software.
//

#import "J3WriteBufferTests.h"
#import "J3WriteBuffer.h"

@interface J3WriteBufferTests (Private)

- (NSString *) output;
- (void) setMaxBytesPerWrite: (size_t) numberOfBytes;
- (void) assertNumberOfWrites: (unsigned) number;
- (void) assertOutputAfterFlushIsString: (NSString *) string;
- (void) assertOutputAfterFlushIsString: (NSString *) string maxBytesPerFlush: (size_t) length;

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
  [self setMaxBytesPerWrite: UINT_MAX];
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
  [self assertOutputAfterFlushIsString: @"" maxBytesPerFlush: 1];
  [self assertNumberOfWrites: 0];
}

- (void) testWriteMultipleTimes
{
  [buffer appendString: @"foo"];
  [buffer appendString: @"bar"];
  [self assertOutputAfterFlushIsString: @"foobar"];
}

- (void) testWriteMultipleTimesWithInterspersedNil
{
  [buffer appendString: @"foo"];
  [buffer appendString: nil];
  [buffer appendString: @"bar"];
  [self assertOutputAfterFlushIsString: @"foobar"];
}

- (void) testClearBufferAndWrite
{
  [buffer appendString: @"foo"];
  [buffer clear];
  [self assertOutputAfterFlushIsString: @"" maxBytesPerFlush: 1];
  [self assertNumberOfWrites: 0];
}

- (void) testClearBufferThenAddMoreAndWrite
{
  [buffer appendString: @"foo"];
  [buffer clear];
  [buffer appendString: @"bar"];
  [self assertOutputAfterFlushIsString: @"bar"];
}

#ifdef TYLER_WILL_FIX
- (void) testRemoveLastCharacterAndWrite
{
  [buffer appendString: @"foop"];
  [buffer removeLastCharacter];
  [self assertOutputAfterFlushIsString: @"foo"];
}
#endif

- (void) testWriteAll
{
  [buffer appendString: @"foo"];
  [self assertOutputAfterFlushIsString: @"foo"];
}

- (void) testWriteSome
{
  [buffer appendString: @"123456"];
  [self assertOutputAfterFlushIsString: @"123456" maxBytesPerFlush: 3];
  [self assertNumberOfWrites: 2];
}

- (void) testWriteLine
{
  [buffer appendLine: @"foo"];
  [self assertOutputAfterFlushIsString: @"foo\n"];
}

- (void) testWriteBytesWithPriority
{
  [buffer appendString: @"foo"];
  [buffer writeDataWithPriority: [NSData dataWithBytes: (uint8_t *)"ab" length: 2]];
  [self assert: [self output] equals: @"ab"];
  [buffer flush];
  [self assert: [self output] equals: @"abfoo"];
}

- (void) testsWriteBytesWithPriorityWithMultipleWrites
{
  [self setMaxBytesPerWrite: 1];
  [buffer appendString: @"foo"];
  [buffer writeDataWithPriority: [NSData dataWithBytes: (uint8_t *)"ab" length: 2]];
  [self assert: [self output] equals: @"ab"];
  [buffer flush];
  [self assert: [self output] equals: @"abfoo"]; 
}

#pragma mark -
#pragma mark J3ByteDestination protocol

- (ssize_t) write: (NSData *) data
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

- (void) assertOutputAfterFlushIsString: (NSString *) string
{
  [self assertOutputAfterFlushIsString: string maxBytesPerFlush: (size_t) [string length]];
  [self assertNumberOfWrites: 1];
}

- (void) assertOutputAfterFlushIsString: (NSString *) string maxBytesPerFlush: (size_t) length
{
  [self setMaxBytesPerWrite: length];
  [buffer flush];
  [self assert: [self output] equals: string];
}

- (void) setMaxBytesPerWrite: (size_t) numberOfBytes
{
  maxBytesPerWrite = numberOfBytes;
}

- (NSString *) output
{
  return [[[NSString alloc] initWithData: output encoding: NSASCIIStringEncoding] autorelease];
}

@end

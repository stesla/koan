//
// J3WriteBufferTests.m
//
// Copyright (c) 2007 3James Software.
//

#import "J3WriteBufferTests.h"
#import "J3WriteBuffer.h"

@interface J3WriteBufferTests (Private)

- (NSString *) output;
- (void) assertOutputAfterFlushIsString: (NSString *) string;

@end

#pragma mark -

@implementation J3WriteBufferTests

- (void) setUp
{
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
  [self assertOutputAfterFlushIsString: @""];
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
  [self assertOutputAfterFlushIsString: @""];
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

#pragma mark -
#pragma mark J3ByteDestination protocol

- (void) write: (NSData *) data
{
  [output appendData: data];
}

@end

#pragma mark -

@implementation J3WriteBufferTests (Private)

- (void) assertOutputAfterFlushIsString: (NSString *) string
{
  [buffer flush];
  [self assert: [self output] equals: string];
}

- (NSString *) output
{
  return [[[NSString alloc] initWithData: output encoding: NSASCIIStringEncoding] autorelease];
}

@end

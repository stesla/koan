//
// J3LineBufferTests.m
//
// Copyright (c) 2005, 2006, 2007 3James Software
//

#import "J3LineBufferTests.h"

@interface J3LineBufferTests (Private)

- (void) bufferBytes: (const uint8_t *) bytes length: (unsigned) length;
- (void) bufferString: (NSString *) string;

@end

#pragma mark -

@implementation J3LineBufferTests

- (void) setUp
{
  buffer = [[J3LineBuffer alloc] init];
  [buffer setByteDestination: self];
  line = nil;
}

- (void) tearDown
{
  [buffer release];
  [line release];
}

- (void) testLineBuffering
{
  [self bufferBytes: (uint8_t *) "12\n" length: 3];
  [self assert: line equals: @"12\n"];
  
  [self bufferBytes: (uint8_t *) "12\n34" length: 5];
  [self assert: line equals: @"12\n"];
  [self bufferBytes: (uint8_t *) "\n" length: 1];
  [self assert: line equals: @"34\n"];
  
  [self bufferString: @"ab\n"];
  [self assert: line equals: @"ab\n"];
  
  [self bufferString: @"ab\ncd"];
  [self assert: line equals: @"ab\n"];
  [self bufferString: @"\n"];
  [self assert: line equals: @"cd\n"];
}

#pragma mark -
#pragma mark J3ByteDestination protocol

- (BOOL) hasSpaceAvailable
{
  return YES;
}

- (unsigned) write: (const uint8_t *) bytes length: (unsigned) length
{
  line = [[NSString alloc] initWithBytes: bytes
                                  length: length
                                encoding: NSASCIIStringEncoding];
  
  return length;
}

@end

#pragma mark -

@implementation J3LineBufferTests (Private)

- (void) bufferBytes: (const uint8_t *) bytes length: (unsigned) length;
{
  [buffer appendBytes: bytes length: length];
}

- (void) bufferString: (NSString *) string
{
  [buffer appendString: string];
}

@end

//
// J3LineBufferTests.m
//
// Copyright (c) 2005, 2006 3James Software
//

#import "J3LineBufferTests.h"

@interface J3LineBufferTests (Private)

- (void) bufferBytes: (const uint8_t *) bytes length: (unsigned) length;
- (void) bufferString: (NSString *) string;

@end

#pragma mark -

@implementation J3LineBufferTests

- (void) lineBufferHasReadLine: (J3LineBuffer *) lineBuffer
{
  line = [lineBuffer readLine];
}

- (void) setUp
{
  buffer = [[J3LineBuffer alloc] init];  
}

- (void) tearDown
{
  [buffer release];
}

- (void) testReadLine
{
  [self bufferBytes: (uint8_t *) "12\n" length: 3];
  [self assert: [buffer readLine] equals: @"12\n"];
  [self bufferString: @"ab\n"];
  [self assert: [buffer readLine] equals: @"ab\n"];
  [self bufferString: @"de\n"];
  [self assert: [buffer readLine] equals: @"de\n"];
}

- (void) testDelegate
{
  [buffer setDelegate: self];
  [self bufferBytes: (uint8_t *) "12\n" length: 3];
  
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

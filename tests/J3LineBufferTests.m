//
// J3LineBufferTests.m
//
// Copyright (c) 2005, 2006 3James Software
//

#import "J3LineBufferTests.h"

@interface J3LineBufferTests (Private)

- (void) bufferString: (NSString *)string;

@end

#pragma mark -

@implementation J3LineBufferTests

- (void) lineBufferHasReadLine: (J3LineBuffer *)lineBuffer
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
  [self bufferString: @"ab\n"];
  [self assert: [buffer readLine] equals: @"ab\n"];
  [self bufferString: @"de\n"];
  [self assert: [buffer readLine] equals: @"de\n"];
}

- (void) testDelegate
{
  [buffer setDelegate: self];
  [self bufferString: @"ab\n"];
  [self assert: line equals: @"ab\n"];
}

@end

#pragma mark -

@implementation J3LineBufferTests (Private)

- (void) bufferString: (NSString *)string
{
  [buffer appendString: string];
}

@end

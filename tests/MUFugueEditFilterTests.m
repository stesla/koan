//
// MUFugueEditFilterTests.m
//
// Copyright (c) 2007 3James Software.
//

#import "MUFugueEditFilterTests.h"
#import "MUFugueEditFilter.h"

@implementation MUFugueEditFilterTests

- (void) setUp
{
  queue = [[J3FilterQueue alloc] init];
  [queue addFilter: [MUFugueEditFilter filter]];
}

- (void) tearDown
{
  [queue release];
}

- (void) testIgnoresNormalInput
{
  [self assertInput: @"Just a normal line of text.\n" hasOutput: @"Just a normal line of text.\n"];
}

- (void) testElidesFugueEdit
{
  [self assertInput: @"FugueEdit > &test me=Test\n" hasOutput: @""];
}

@end

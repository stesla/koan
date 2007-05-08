//
// MUFugueEditFilterTests.m
//
// Copyright (c) 2007 3James Software.
//

#import "MUFugueEditFilterTests.h"
#import "MUFugueEditFilter.h"

@implementation MUFugueEditFilterTests

- (void) setInputViewString: (NSString *) string
{
  editString = [string copy];
}

- (void) setUp
{
  editString = nil;
  queue = [[J3FilterQueue alloc] init];
  [queue addFilter: [MUFugueEditFilter filterWithDelegate: self]];
}

- (void) tearDown
{
  [queue release];
  [editString release];
}

- (void) testIgnoresNormalInput
{
  [self assertInput: @"Just a normal line of text.\n" hasOutput: @"Just a normal line of text.\n"];
  [self assertNil: editString]; 
}

- (void) testElidesFugueEdit
{
  [self assertInput: @"FugueEdit > &test me=Test\n" hasOutput: @""];
  [self assert: editString equals: @"&test me=Test"];
}

@end

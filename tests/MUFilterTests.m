//
// MUFilterTests.m
//
// Copyright (C) 2004 3James Software
//

#import "MUFilterTests.h"

@implementation MUFilterTests

- (void) testFilter
{
  MUFilter *filter = [MUFilter filter];
  NSAttributedString *input = [NSAttributedString attributedStringWithString:@"Foo"];

  NSAttributedString *output = [filter filter:input];
  
  [self assert:output equals:input];
}

@end

@implementation MUUpperCaseFilter

- (NSAttributedString *) filter:(NSAttributedString *)string
{
  return [NSAttributedString attributedStringWithString:[[string string] uppercaseString]
                                             attributes:[string attributesAtIndex:0 effectiveRange:0]];
}

@end

@implementation MUFilterQueueTests

- (void) testFilter
{
  MUFilterQueue *queue = [[MUFilterQueue alloc] init];
  NSAttributedString *input = [NSAttributedString attributedStringWithString:@"Foo"];
  NSAttributedString *output = [queue processAttributedString:input];
  [self assert:output equals:input];
}

- (void) testQueue
{
  MUFilterQueue *queue = [[MUFilterQueue alloc] init];
  MUUpperCaseFilter *filter = [[MUUpperCaseFilter alloc] init];
  [queue addFilter:filter];
  
  NSAttributedString *input = [NSAttributedString attributedStringWithString:@"Foo"];
  NSAttributedString *output = [queue processAttributedString:input];
  [self assert:[output string] equals:@"FOO"];
  [queue release];
}

@end

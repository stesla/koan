//
// J3FilterTests.m
//
// Copyright (c) 2007 3James Software.
//

#import "J3FilterTests.h"

@implementation J3FilterTests

- (void) testFilter
{
  J3Filter *filter = [J3Filter filter];
  NSAttributedString *input = [NSAttributedString attributedStringWithString: @"Foo"];

  NSAttributedString *output = [filter filter: input];
  
  [self assert: output equals: input];
}

@end

#pragma mark -

@implementation J3UpperCaseFilter

- (NSAttributedString *) filter: (NSAttributedString *) string
{
  return [NSAttributedString attributedStringWithString: [[string string] uppercaseString]
                                             attributes: [string attributesAtIndex: 0 effectiveRange: 0]];
}

@end

#pragma mark -

@implementation J3FilterQueueTests

- (void) testFilter
{
  J3FilterQueue *queue = [[J3FilterQueue alloc] init];
  NSAttributedString *input = [NSAttributedString attributedStringWithString: @"Foo"];
  NSAttributedString *output = [queue processAttributedString: input];
  [self assert: output equals: input];
}

- (void) testQueue
{
  J3FilterQueue *queue = [[J3FilterQueue alloc] init];
  J3UpperCaseFilter *filter = [J3UpperCaseFilter filter];
  [queue addFilter: filter];
  
  NSAttributedString *input = [NSAttributedString attributedStringWithString: @"Foo"];
  NSAttributedString *output = [queue processAttributedString: input];
  [self assert: [output string] equals: @"FOO"];
  [queue release];
}

@end

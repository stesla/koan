//
//  MUInputFilterTests.m
//  Koan
//
//  Created by Samuel on 11/12/04.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import "MUInputFilterTests.h"
#import "MUInputFilter.h"

@implementation MUInputFilterTests

- (void) filter:(NSAttributedString *)string
{
  _output = string;
}

- (void) testFilter
{
  MUInputFilter *filter = [[MUInputFilter alloc] init];
  [filter setSuccessor:self];
  
  NSAttributedString *input =
    [[NSAttributedString alloc] initWithString:@"Foo"];
  
  [filter filter:input];
  
  [self assert:_output equals:input];
}

@end

//
//  MUAnsiRemovingFilterTests.m
//  Koan
//
//  Created by Samuel on 11/14/04.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import "MUAnsiRemovingFilterTests.h"
#import "MUInputFilter.h"
#import "MUAnsiRemovingFilter.h"

@implementation MUAnsiRemovingFilterTests

- (void) testNoCode
{
  MUInputFilterQueue *queue = [[MUInputFilterQueue alloc] init];
  [queue addFilter:[MUAnsiRemovingFilter filter]];
  [self assert:[queue processString:@"Foo"] equals:@"Foo"];
  [queue release];
}

- (void) testBasicCodeCode
{
  MUInputFilterQueue *queue = [[MUInputFilterQueue alloc] init];
  [queue addFilter:[MUAnsiRemovingFilter filter]];
  [self assert:[queue processString:@"F\033[moo"] equals:@"Foo"];
  [self assert:[queue processString:@"F\033[3moo"] equals:@"Foo"];
  [self assert:[queue processString:@"F\033[36moo"] equals:@"Foo"];
  [queue release];
}

- (void) testTwoCodes
{
  MUInputFilterQueue *queue = [[MUInputFilterQueue alloc] init];
  [queue addFilter:[MUAnsiRemovingFilter filter]];
  [self assert:[queue processString:@"F\033[36mo\033[3mo"] equals:@"Foo"];
  [queue release];
}

@end

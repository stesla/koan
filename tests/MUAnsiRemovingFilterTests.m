//
//  MUAnsiRemovingFilterTests.m
//  Koan
//
//  Created by Samuel on 11/14/04.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import "MUAnsiRemovingFilterTests.h"
#import "MUAnsiRemovingFilter.h"

@interface MUAnsiRemovingFilterTests (Private)
- (void) assertInput:(NSString *)input hasOutput:(NSString *)output;
- (void) assertInput:(NSString *)input hasOutput:(NSString *)output
             message:(NSString *)message;
@end

@implementation MUAnsiRemovingFilterTests (Private)

- (void) assertInput:(NSString *)input hasOutput:(NSString *)output
{
  [self assert:[_queue processString:input] equals:output];
}

- (void) assertInput:(NSString *)input hasOutput:(NSString *)output
             message:(NSString *)message
{
  [self assert:[_queue processString:input] equals:output
       message:message];
}

@end

@implementation MUAnsiRemovingFilterTests

- (void) setUp
{
  _queue = [[MUInputFilterQueue alloc] init];
  [_queue addFilter:[MUAnsiRemovingFilter filter]];
}

- (void) tearDown
{
  [_queue release];
}

- (void) testNoCode
{
  [self assertInput:@"Foo" hasOutput:@"Foo"];
}

- (void) testBasicCode
{
  [self assertInput:@"F\033[moo" hasOutput:@"Foo"
            message:@"One"];
  [self assertInput:@"F\033[3moo" hasOutput:@"Foo"
            message:@"Two"];
  [self assertInput:@"F\033[36moo" hasOutput:@"Foo"
            message:@"Three"];
}

- (void) testTwoCodes
{
  [self assertInput:@"F\033[36moa\033[3mob" hasOutput:@"Foaob"];
}

- (void) testNewLine
{
  [self assertInput:@"Foo\n" hasOutput:@"Foo\n"];
}

- (void) testCodeAtEndOfLine
{
  [self assertInput:@"Foo\033[36m\n" hasOutput:@"Foo\n"];
}

- (void) testCodeAtEndOfString
{
  [self assertInput:@"Foo\033[36m" hasOutput:@"Foo"];
}

- (void) testEmptyString
{
  [self assertInput:@"" hasOutput:@""];
}

- (void) testOnlyCode
{
  [self assertInput:@"\033[36m" hasOutput:@""];
}

- (void) testLongString
{
  NSString *longString = 
    @"        #@@N         (@@)     (@@@)        J@@@@F      @@@@@@@L";
  [self assertInput:longString hasOutput:longString];
}

@end

//
//  J3NaiveANSIFilterTests.m
//  Koan
//
//  Created by Samuel on 1/25/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "J3NaiveANSIFilterTests.h"

#import "J3NaiveANSIFilter.h"
#import "TestCase (NSAttributedStringAssertions).h"

@interface J3NaiveANSIFilterTests (Private)
- (NSAttributedString *) makeString:(NSString *)string;
@end

@implementation J3NaiveANSIFilterTests

- (void) setUp
{
  filter = (J3NaiveANSIFilter *)[J3NaiveANSIFilter filter];
}

- (void) testNoCode
{
  NSAttributedString *input = [self makeString:@"Foo"];
  [self assertAttributedString:[filter filter:input]
                  stringEquals:@"Foo"];
}

- (void) testExtractsCode
{
  NSAttributedString *input = [self makeString:@"F\x1B[0moo"];
  
  [self assertAttributedString:[filter filter:input]
                  stringEquals:@"Foo"];
  
  input = [self makeString:@"F\x1B[moo"];
  [self assertAttributedString:input
                  stringEquals:[input string]];
}

- (void) testSetsColor
{
  NSAttributedString *input = [self makeString:@"F\x1B[31moo"];
  NSRange range;
  
  range.location = 1;
  range.location = 2; // "oo"
  
  [self assertAttribute:J3ANSIForeColorAttributeName
                 equals:[NSColor redColor]
               inString:[filter filter:input]
              withRange:range];
}

@end

@implementation J3NaiveANSIFilterTests (Private)

- (NSAttributedString *) makeString:(NSString *)string
{
  return [NSAttributedString attributedStringWithString:string];
}

@end

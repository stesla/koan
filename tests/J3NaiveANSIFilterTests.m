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

- (void) assertANSICode:(J3ANSICode)code 
          setsAttribute:(NSString *)aName 
                toValue:(id)aValue;
- (void) assertANSICode:(J3ANSICode)code setsForegroundColor:(NSColor *)color;
- (void) assertANSICode:(J3ANSICode)code setsBackColor:(NSColor *)color;
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
                  equalsString:@"Foo"];
}

- (void) testExtractsCode
{
  NSAttributedString *input = [self makeString:@"F\x1B[0moo"];

  [self assertAttributedString:[filter filter:input]
                  equalsString:@"Foo"];

  input = [self makeString:@"F\x1B[moo"];
  [self assertAttributedString:input
                  equalsString:[input string]];
}

- (void) testSetsSpecificForegroundColor
{
  [self assertANSICode:J3ANSIForegroundBlack setsForegroundColor:[NSColor blackColor]];
  [self assertANSICode:J3ANSIForegroundRed setsForegroundColor:[NSColor redColor]];
  [self assertANSICode:J3ANSIForegroundGreen setsForegroundColor:[NSColor greenColor]];
  [self assertANSICode:J3ANSIForegroundYellow setsForegroundColor:[NSColor yellowColor]];
  [self assertANSICode:J3ANSIForegroundBlue setsForegroundColor:[NSColor blueColor]];
  [self assertANSICode:J3ANSIForegroundMagenta setsForegroundColor:[NSColor magentaColor]];
  [self assertANSICode:J3ANSIForegroundCyan setsForegroundColor:[NSColor cyanColor]];
  [self assertANSICode:J3ANSIForegroundWhite setsForegroundColor:[NSColor whiteColor]];
}

- (void) testSetsSpecificBackColor
{
  [self assertANSICode:J3ANSIBackBlack setsBackColor:[NSColor blackColor]];
  [self assertANSICode:J3ANSIBackRed setsBackColor:[NSColor redColor]];
  [self assertANSICode:J3ANSIBackGreen setsBackColor:[NSColor greenColor]];
  [self assertANSICode:J3ANSIBackYellow setsBackColor:[NSColor yellowColor]];
  [self assertANSICode:J3ANSIBackBlue setsBackColor:[NSColor blueColor]];
  [self assertANSICode:J3ANSIBackMagenta setsBackColor:[NSColor magentaColor]];
  [self assertANSICode:J3ANSIBackCyan setsBackColor:[NSColor cyanColor]];
  [self assertANSICode:J3ANSIBackWhite setsBackColor:[NSColor whiteColor]];
}

/*
- (void) testDefaultForeground
{
  NSRange range;
  NSAttributedString *input =
    [self makeString:[NSString stringWithFormat:
      @"F\x1B[%dmo\x1B[%dmo", J3ANSIForegroundRed, J3ANSIForegroundDefault]];
  NSColor *color =
    [input attribute:NSForegroundColorAttributeName
             atIndex:[input length] - 1
      effectiveRange:NULL];
  NSAttributedString *output =
    [filter filter:input];
  
  range.location = 2;
  range.length = 1;
  
  [self assertAttribute:J3ANSIForegroundColorAttributeName
                 equals:color
               inString:output
                atIndex:[output length] -1];
}
*/

@end

@implementation J3NaiveANSIFilterTests (Private)

- (NSAttributedString *) makeString:(NSString *)string
{
  return [NSAttributedString attributedStringWithString:string];
}

- (void) assertANSICode:(J3ANSICode)code 
          setsAttribute:(NSString *)aName 
                toValue:(id)aValue
{
  NSAttributedString *input =
    [self makeString:[NSString stringWithFormat:@"F\x1B[%dmoo", code]];
  NSRange range;
  
  range.location = 1;
  range.length = 2; // "oo"
  
  [self assertAttribute:aName
                 equals:aValue
     inAttributedString:[filter filter:input]
              withRange:range];  
}

- (void) assertANSICode:(J3ANSICode)code setsForegroundColor:(NSColor *)color
{
  [self assertANSICode:code
         setsAttribute:J3ANSIForegroundColorAttributeName
               toValue:color];
}

- (void) assertANSICode:(J3ANSICode)code setsBackColor:(NSColor *)color
{
  [self assertANSICode:code
         setsAttribute:J3ANSIBackgroundColorAttributeName
               toValue:color];
}

@end

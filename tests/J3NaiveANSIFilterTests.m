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
- (void) assertANSICode:(J3ANSICode)code setsForeColor:(NSColor *)color;
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

- (void) testSetsSpecificForeColor
{
  [self assertANSICode:J3ANSIForeBlack setsForeColor:[NSColor blackColor]];
  [self assertANSICode:J3ANSIForeRed setsForeColor:[NSColor redColor]];
  [self assertANSICode:J3ANSIForeGreen setsForeColor:[NSColor greenColor]];
  [self assertANSICode:J3ANSIForeYellow setsForeColor:[NSColor yellowColor]];
  [self assertANSICode:J3ANSIForeBlue setsForeColor:[NSColor blueColor]];
  [self assertANSICode:J3ANSIForeMagenta setsForeColor:[NSColor magentaColor]];
  [self assertANSICode:J3ANSIForeCyan setsForeColor:[NSColor cyanColor]];
  [self assertANSICode:J3ANSIForeWhite setsForeColor:[NSColor whiteColor]];
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
- (void) testDefaultFore
{
  NSRange range;
  NSAttributedString *input =
    [self makeString:[NSString stringWithFormat:
      @"F\x1B[%dmo\x1B[%dmo", J3ANSIForeRed, J3ANSIForeDefault]];
  NSColor *color =
    [input attribute:NSForegroundColorAttributeName
             atIndex:[input length] - 1
      effectiveRange:NULL];
  NSAttributedString *output =
    [filter filter:input];
  
  range.location = 2;
  range.length = 1;
  
  [self assertAttribute:J3ANSIForeColorAttributeName
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

- (void) assertANSICode:(J3ANSICode)code setsForeColor:(NSColor *)color
{
  [self assertANSICode:code
         setsAttribute:J3ANSIForeColorAttributeName
               toValue:color];
}

- (void) assertANSICode:(J3ANSICode)code setsBackColor:(NSColor *)color
{
  [self assertANSICode:code
         setsAttribute:J3ANSIBackColorAttributeName
               toValue:color];
}

@end

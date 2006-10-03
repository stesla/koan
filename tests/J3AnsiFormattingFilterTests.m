//
// J3AnsiFormattingFilterTests.m
//
// Copyright (c) 2004, 2005 3James Software
//

#import "J3AnsiFormattingFilterTests.h"
#import "J3AnsiFormattingFilter.h"
#import "J3Formatting.h"
#import "NSFont (Traits).h"

@interface J3AnsiFormattingFilterTests (Private)
- (void) assertInput:(NSString *)input hasOutput:(NSString *)output;
- (void) assertInput:(NSString *)input hasOutput:(NSString *)output
             message:(NSString *)message;
- (void) assertFinalCharacter:(unsigned char)finalChar;
- (void) assertString:(NSAttributedString *)string hasValue:(id)value forAttribute:(NSString *)attribute atIndex:(int)index message:(NSString *)message;
- (void) assertString:(NSAttributedString *)string isBoldAtIndex:(int)index message:(NSString *)message;
- (void) assertString:(NSAttributedString *)string isNotBoldAtIndex:(int)index message:(NSString *)message;
- (NSMutableAttributedString *) makeString:(NSString *)string;
@end

#pragma mark -

@implementation J3AnsiFormattingFilterTests (Private)

- (void) assertInput:(NSString *)input hasOutput:(NSString *)output
{
  [self assertInput:input hasOutput:output message:nil];
}

- (void) assertInput:(NSString *)input hasOutput:(NSString *)output
             message:(NSString *)message
{
  NSAttributedString *attributedInput = [self makeString:input];
  NSAttributedString *attributedExpectedOutput = [NSAttributedString attributedStringWithString:output];
  NSMutableAttributedString *actualOutput = [NSMutableAttributedString attributedStringWithAttributedString:[queue processAttributedString:attributedInput]];
  NSRange range;
  range.location = 0;
  range.length = [actualOutput length];
  [actualOutput setAttributes:[NSDictionary dictionary] range:range];
  [self assert:actualOutput equals:attributedExpectedOutput message:message];  
}

- (void) assertFinalCharacter:(unsigned char)finalChar
{
  [self assertInput:[NSString stringWithFormat:@"F\x1B[%coo", finalChar]
          hasOutput:@"Foo"
            message:[NSString stringWithFormat:@"[%X]", finalChar]];
}

- (void) assertString:(NSAttributedString *)string hasValue:(id)value forAttribute:(NSString *)attribute atIndex:(int)index message:(NSString *)message;
{
  NSDictionary * attributes = [string attributesAtIndex:index effectiveRange:NULL];
  [self assert:[attributes valueForKey:attribute] equals:value message:message]; 
}

- (void) assertString:(NSAttributedString *)string isBoldAtIndex:(int)index message:(NSString *)message;
{
  NSFont * font = [string attribute:NSFontAttributeName atIndex:index effectiveRange:NULL];
  [self assertTrue:[font hasTrait:NSBoldFontMask] message:message];
  
}

- (void) assertString:(NSAttributedString *)string isNotBoldAtIndex:(int)index message:(NSString *)message;
{
  NSFont * font = [string attribute:NSFontAttributeName atIndex:index effectiveRange:NULL];
  [self assertFalse:[font hasTrait:NSBoldFontMask] message:message];
}

- (NSMutableAttributedString *) makeString:(NSString *)string;
{
  NSFont * font = [NSFont systemFontOfSize:[NSFont systemFontSize]];
  NSMutableDictionary * attributes = [NSMutableDictionary dictionary];
  [attributes setValue:font forKey:NSFontAttributeName];
  return [NSMutableAttributedString attributedStringWithString:string attributes:attributes];
}

@end

#pragma mark -

@implementation J3AnsiFormattingFilterTests

- (void) setUp
{
  queue = [[J3FilterQueue alloc] init];
  [queue addFilter:[J3AnsiFormattingFilter filter]];
}

- (void) tearDown
{
  [queue release];
}

- (void) testNoCode
{
  [self assertInput:@"Foo"
          hasOutput:@"Foo"];
}

- (void) testSingleCharacter
{
  [self assertInput:@"Q"
          hasOutput:@"Q"];
}

- (void) testBasicCode
{
  [self assertInput:@"F\x1B[moo"
          hasOutput:@"Foo"
            message:@"One"];
  [self assertInput:@"F\x1B[3moo"
          hasOutput:@"Foo"
            message:@"Two"];
  [self assertInput:@"F\x1B[36moo"
          hasOutput:@"Foo"
            message:@"Three"];
}

- (void) testTwoCodes
{
  [self assertInput:@"F\x1B[36moa\x1B[3mob"
          hasOutput:@"Foaob"];
}

- (void) testNewLine
{
  [self assertInput:@"Foo\n"
          hasOutput:@"Foo\n"];
}

- (void) testOnlyNewLine
{
  [self assertInput:@"\n"
          hasOutput:@"\n"];
}

- (void) testCodeAtEndOfLine
{
  [self assertInput:@"Foo\x1B[36m\n"
          hasOutput:@"Foo\n"];
}

- (void) testCodeAtBeginningOfString
{
  [self assertInput:@"\x1B[36mFoo"
          hasOutput:@"Foo"];
}

- (void) testCodeAtEndOfString
{
  [self assertInput:@"Foo\x1B[36m"
          hasOutput:@"Foo"];
}

- (void) testEmptyString
{
  [self assertInput:@"" 
          hasOutput:@""];
}

- (void) testOnlyCode
{
  [self assertInput:@"\x1B[36m"
          hasOutput:@""];
}

- (void) testLongString
{
  NSString *longString = 
    @"        #@@N         (@@)     (@@@)        J@@@@F      @@@@@@@L";
  [self assertInput:longString
          hasOutput:longString];
}

- (void) testOnlyWhitespaceBeforeCodeAndNothingAfterIt;
{
  [self assertInput:@" \x1B[1m"
          hasOutput:@" "];
}

- (void) testForegroundColor;
{
  NSAttributedString * input = [self makeString:@"a\x1B[36mbc\x1B[35md\x1B[39me"];
  NSAttributedString * output = [queue processAttributedString:input];
  
  [self assertString:output hasValue:nil forAttribute:NSForegroundColorAttributeName atIndex:0 message:@"a"];
  [self assertString:output hasValue:[NSColor cyanColor] forAttribute:NSForegroundColorAttributeName atIndex:1 message:@"b"];
  [self assertString:output hasValue:[NSColor cyanColor] forAttribute:NSForegroundColorAttributeName atIndex:2 message:@"c"];
  [self assertString:output hasValue:[NSColor magentaColor] forAttribute:NSForegroundColorAttributeName atIndex:3 message:@"d"];
  [self assertString:output hasValue:[J3Formatting testingForeground] forAttribute:NSForegroundColorAttributeName atIndex:4 message:@"e"];
}

- (void) testBackgroundColor;
{
  NSAttributedString * input = [self makeString:@"a\x1B[46mbc\x1B[45md\x1B[49me"];
  NSAttributedString * output = [queue processAttributedString:input];
  
  [self assertString:output hasValue:nil forAttribute:NSForegroundColorAttributeName atIndex:0 message:@"a"];
  [self assertString:output hasValue:[NSColor cyanColor] forAttribute:NSBackgroundColorAttributeName atIndex:1 message:@"b"];
  [self assertString:output hasValue:[NSColor cyanColor] forAttribute:NSBackgroundColorAttributeName atIndex:2 message:@"c"];
  [self assertString:output hasValue:[NSColor magentaColor] forAttribute:NSBackgroundColorAttributeName atIndex:3 message:@"d"];
  [self assertString:output hasValue:[J3Formatting testingBackground] forAttribute:NSBackgroundColorAttributeName atIndex:4 message:@"e"];
}

- (void) testResetForeAndBack;
{
  NSAttributedString * input = [self makeString:@"a\x1B[36m\x1B[46mb\x1B[0mc"];
  NSAttributedString * output = [queue processAttributedString:input];
  
  [self assertString:output hasValue:[NSColor cyanColor] forAttribute:NSBackgroundColorAttributeName atIndex:1 message:@"b background"];
  [self assertString:output hasValue:[NSColor cyanColor] forAttribute:NSForegroundColorAttributeName atIndex:1 message:@"b foreground"];
  [self assertString:output hasValue:[J3Formatting testingBackground] forAttribute:NSBackgroundColorAttributeName atIndex:2 message:@"c background"];  
  [self assertString:output hasValue:[J3Formatting testingForeground] forAttribute:NSForegroundColorAttributeName atIndex:2 message:@"c foreground"];  
}

- (void) testPersistColorsBetweenLines;
{
  NSAttributedString * firstInput = [self makeString:@"a\x1B[36mb"];
  NSAttributedString * secondInput = [self makeString:@"c"];
  NSAttributedString * output;
  
  [queue processAttributedString:firstInput];
  output = [queue processAttributedString:secondInput];
  
  [self assertString:output hasValue:[NSColor cyanColor] forAttribute:NSForegroundColorAttributeName atIndex:0 message:@"c"];
}

- (void) testBold;
{
  NSAttributedString * input = [self makeString:@"a\x1B[1mb\x1B[22mc\x1B[1md\x1B[0me"];
  NSAttributedString * output = [queue processAttributedString:input];

  [self assertString:output isNotBoldAtIndex:0 message:@"a"];
  [self assertString:output isBoldAtIndex:1 message:@"b"];
  [self assertString:output isNotBoldAtIndex:2 message:@"c"];
  [self assertString:output isBoldAtIndex:3 message:@"d"];
  [self assertString:output isNotBoldAtIndex:4 message:@"e"];
}

- (void) testBoldWithBoldAlreadyOn;
{
  NSMutableAttributedString * input = [self makeString:@"a\x1B[1mb\x1B[22mc\x1B[1md\x1B[0me"];
  NSAttributedString * output; 
  NSFont * boldFont = [[J3Formatting testingFont] fontWithTrait:NSBoldFontMask];
  
  [queue clearFilters];
  [queue addFilter:[J3AnsiFormattingFilter filterWithFormatting:[J3Formatting formattingWithForegroundColor:[J3Formatting testingForeground] backgroundColor:[J3Formatting testingBackground] font:boldFont]]];

  output = [queue processAttributedString:input];
  [self assertString:output isBoldAtIndex:0 message:@"a"];
  [self assertString:output isNotBoldAtIndex:1 message:@"b"];
  [self assertString:output isBoldAtIndex:2 message:@"c"];
  [self assertString:output isNotBoldAtIndex:3 message:@"d"];
  [self assertString:output isBoldAtIndex:4 message:@"e"];
  
  output = [queue processAttributedString:input];
  [self assertString:output isBoldAtIndex:0 message:@"a2"];
}

@end

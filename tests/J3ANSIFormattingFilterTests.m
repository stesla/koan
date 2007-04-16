//
// J3ANSIFormattingFilterTests.m
//
// Copyright (c) 2007 3James Software.
//

#import "J3ANSIFormattingFilterTests.h"
#import "J3ANSIFormattingFilter.h"
#import "J3Formatting.h"
#import "NSFont (Traits).h"

@interface J3ANSIFormattingFilterTests (Private)

- (void) assertInput: (NSString *) input hasOutput: (NSString *) output;
- (void) assertInput: (NSString *) input
           hasOutput: (NSString *) output
             message: (NSString *) message;
- (void) assertFinalCharacter: (unsigned char) finalChar;
- (void) assertString: (NSAttributedString *) string
             hasValue: (id) value
         forAttribute: (NSString *) attribute
              atIndex: (int) characterIndex
              message: (NSString *) message;
- (void) assertString: (NSAttributedString *) string
             hasTrait: (NSFontTraitMask) trait
              atIndex: (int) characterIndex
              message: (NSString *) message;
- (NSMutableAttributedString *) makeString: (NSString *) string;

@end

#pragma mark -

@implementation J3ANSIFormattingFilterTests (Private)

- (void) assertInput: (NSString *) input hasOutput: (NSString *) output
{
  [self assertInput: input hasOutput: output message: nil];
}

- (void) assertInput: (NSString *) input hasOutput: (NSString *) output
             message: (NSString *) message
{
  NSAttributedString *attributedInput = [self makeString: input];
  NSAttributedString *attributedExpectedOutput = [NSAttributedString attributedStringWithString: output];
  NSMutableAttributedString *actualOutput = [NSMutableAttributedString attributedStringWithAttributedString: [queue processAttributedString: attributedInput]];
  NSRange range;
  range.location = 0;
  range.length = [actualOutput length];
  [actualOutput setAttributes: [NSDictionary dictionary] range: range];
  [self assert: actualOutput equals: attributedExpectedOutput message: message];  
}

- (void) assertFinalCharacter: (unsigned char) finalChar
{
  [self assertInput: [NSString stringWithFormat: @"F\x1B[%coo", finalChar]
          hasOutput: @"Foo"
            message: [NSString stringWithFormat: @"[%X]", finalChar]];
}

- (void) assertString: (NSAttributedString *) string
             hasValue: (id) value
         forAttribute: (NSString *) attribute
              atIndex: (int) characterIndex
              message: (NSString *) message
{
  NSDictionary * attributes = [string attributesAtIndex: characterIndex effectiveRange: NULL];
  [self assert: [attributes valueForKey: attribute] equals: value message: message];
}

- (void) assertString: (NSAttributedString *) string
             hasTrait: (NSFontTraitMask) trait
              atIndex: (int) characterIndex
              message: (NSString *) message
{
  NSFont * font = [string attribute: NSFontAttributeName atIndex: characterIndex effectiveRange: NULL];
  [self assertTrue: [font hasTrait: trait] message: message];
}

- (NSMutableAttributedString *) makeString: (NSString *) string
{
  NSFont * font = [NSFont systemFontOfSize: [NSFont systemFontSize]];
  NSMutableDictionary * attributes = [NSMutableDictionary dictionary];
  [attributes setValue: font forKey: NSFontAttributeName];
  return [NSMutableAttributedString attributedStringWithString: string attributes: attributes];
}

@end

#pragma mark -

@implementation J3ANSIFormattingFilterTests

- (void) setUp
{
  queue = [[J3FilterQueue alloc] init];
  [queue addFilter: [J3ANSIFormattingFilter filter]];
}

- (void) tearDown
{
  [queue release];
}

- (void) testNoCode
{
  [self assertInput: @"Foo"
          hasOutput: @"Foo"];
}

- (void) testSingleCharacter
{
  [self assertInput: @"Q"
          hasOutput: @"Q"];
}

- (void) testBasicCode
{
  [self assertInput: @"F\x1B[moo"
          hasOutput: @"Foo"
            message: @"One"];
  [self assertInput: @"F\x1B[3moo"
          hasOutput: @"Foo"
            message: @"Two"];
  [self assertInput: @"F\x1B[36moo"
          hasOutput: @"Foo"
            message: @"Three"];
}

- (void) testTwoCodes
{
  [self assertInput: @"F\x1B[36moa\x1B[3mob"
          hasOutput: @"Foaob"];
}

- (void) testNewLine
{
  [self assertInput: @"Foo\n"
          hasOutput: @"Foo\n"];
}

- (void) testOnlyNewLine
{
  [self assertInput: @"\n"
          hasOutput: @"\n"];
}

- (void) testCodeAtEndOfLine
{
  [self assertInput: @"Foo\x1B[36m\n"
          hasOutput: @"Foo\n"];
}

- (void) testCodeAtBeginningOfString
{
  [self assertInput: @"\x1B[36mFoo"
          hasOutput: @"Foo"];
}

- (void) testCodeAtEndOfString
{
  [self assertInput: @"Foo\x1B[36m"
          hasOutput: @"Foo"];
}

- (void) testEmptyString
{
  [self assertInput: @""
          hasOutput: @""];
}

- (void) testOnlyCode
{
  [self assertInput: @"\x1B[36m"
          hasOutput: @""];
}

- (void) testCodeSplitOverTwoStrings
{
  [self assertInput: @"\x1B[" hasOutput: @""];
  [self assertInput: @"36m" hasOutput: @""];
}

- (void) testCodeWithJustTerminatorInSecondString
{
  [self assertInput: @"\x1B[36" hasOutput: @""];
  [self assertInput: @"m" hasOutput: @""];
}

- (void) testLongString
{
  NSString *longString =
    @"        #@@N         (@@)     (@@@)        J@@@@F      @@@@@@@L";
  [self assertInput: longString
          hasOutput: longString];
}

- (void) testOnlyWhitespaceBeforeCodeAndNothingAfterIt
{
  [self assertInput: @" \x1B[1m"
          hasOutput: @" "];
}

- (void) testForegroundColor
{
  NSAttributedString *input = [self makeString: @"a\x1B[36mbc\x1B[35md\x1B[39me"];
  NSAttributedString *output = [queue processAttributedString: input];
  
  [self assertString: output hasValue: nil forAttribute: NSForegroundColorAttributeName atIndex: 0 message: @"a"];
  [self assertString: output hasValue: [NSColor cyanColor] forAttribute: NSForegroundColorAttributeName atIndex: 1 message: @"b"];
  [self assertString: output hasValue: [NSColor cyanColor] forAttribute: NSForegroundColorAttributeName atIndex: 2 message: @"c"];
  [self assertString: output hasValue: [NSColor magentaColor] forAttribute: NSForegroundColorAttributeName atIndex: 3 message: @"d"];
  [self assertString: output hasValue: [J3Formatting testingForeground] forAttribute: NSForegroundColorAttributeName atIndex: 4 message: @"e"];
}

- (void) testBackgroundColor
{
  NSAttributedString *input = [self makeString: @"a\x1B[46mbc\x1B[45md\x1B[49me"];
  NSAttributedString *output = [queue processAttributedString: input];
  
  [self assertString: output hasValue: nil forAttribute: NSForegroundColorAttributeName atIndex: 0 message: @"a"];
  [self assertString: output hasValue: [NSColor cyanColor] forAttribute: NSBackgroundColorAttributeName atIndex: 1 message: @"b"];
  [self assertString: output hasValue: [NSColor cyanColor] forAttribute: NSBackgroundColorAttributeName atIndex: 2 message: @"c"];
  [self assertString: output hasValue: [NSColor magentaColor] forAttribute: NSBackgroundColorAttributeName atIndex: 3 message: @"d"];
  [self assertString: output hasValue: [J3Formatting testingBackground] forAttribute: NSBackgroundColorAttributeName atIndex: 4 message: @"e"];
}

- (void) testResetDisplayMode
{
  NSAttributedString *input = [self makeString: @"a\x1B[36m\x1B[46mb\x1B[0mc"];
  NSAttributedString *output = [queue processAttributedString: input];
  
  [self assertString: output hasValue: [NSColor cyanColor] forAttribute: NSBackgroundColorAttributeName atIndex: 1 message: @"b background"];
  [self assertString: output hasValue: [NSColor cyanColor] forAttribute: NSForegroundColorAttributeName atIndex: 1 message: @"b foreground"];
  [self assertString: output hasValue: [J3Formatting testingBackground] forAttribute: NSBackgroundColorAttributeName atIndex: 2 message: @"c background"];  
  [self assertString: output hasValue: [J3Formatting testingForeground] forAttribute: NSForegroundColorAttributeName atIndex: 2 message: @"c foreground"];  
}

- (void) testShortFormOfResetDisplayMode
{
  NSAttributedString *input = [self makeString: @"a\x1B[36m\x1B[46mb\x1B[mc"];
  NSAttributedString *output = [queue processAttributedString: input];
  
  [self assertString: output hasValue: [NSColor cyanColor] forAttribute: NSBackgroundColorAttributeName atIndex: 1 message: @"b background"];
  [self assertString: output hasValue: [NSColor cyanColor] forAttribute: NSForegroundColorAttributeName atIndex: 1 message: @"b foreground"];
  [self assertString: output hasValue: [J3Formatting testingBackground] forAttribute: NSBackgroundColorAttributeName atIndex: 2 message: @"c background"];  
  [self assertString: output hasValue: [J3Formatting testingForeground] forAttribute: NSForegroundColorAttributeName atIndex: 2 message: @"c foreground"]; 
}

- (void) testPersistColorsBetweenLines
{
  NSAttributedString *firstInput = [self makeString: @"a\x1B[36mb"];
  NSAttributedString *secondInput = [self makeString: @"c"];
  NSAttributedString *output;
  
  [queue processAttributedString: firstInput];
  output = [queue processAttributedString: secondInput];
  
  [self assertString: output hasValue: [NSColor cyanColor] forAttribute: NSForegroundColorAttributeName atIndex: 0 message: @"c"];
}

- (void) testBold
{
  NSAttributedString *input = [self makeString: @"a\x1B[1mb\x1B[22mc\x1B[1md\x1B[0me"];
  NSAttributedString *output = [queue processAttributedString: input];

  [self assertString: output hasTrait: NSUnboldFontMask atIndex: 0 message: @"a"];
  [self assertString: output hasTrait: NSBoldFontMask atIndex: 1 message: @"b"];
  [self assertString: output hasTrait: NSUnboldFontMask atIndex: 2 message: @"c"];
  [self assertString: output hasTrait: NSBoldFontMask atIndex: 3 message: @"d"];
  [self assertString: output hasTrait: NSUnboldFontMask atIndex: 4 message: @"e"];
}

- (void) testBoldWithBoldAlreadyOn
{
  NSMutableAttributedString *input = [self makeString: @"a\x1B[1mb\x1B[22mc\x1B[1md\x1B[0me"];
  NSAttributedString *output;
  NSFont *boldFont = [[J3Formatting testingFont] fontWithTrait: NSBoldFontMask];
  
  [queue clearFilters];
  [queue addFilter: [J3ANSIFormattingFilter filterWithFormatting: [J3Formatting formattingWithForegroundColor: [J3Formatting testingForeground] backgroundColor: [J3Formatting testingBackground] font: boldFont]]];

  output = [queue processAttributedString: input];
  [self assertString: output hasTrait: NSBoldFontMask atIndex: 0 message: @"a"];
  [self assertString: output hasTrait: NSUnboldFontMask atIndex: 1 message: @"b"];
  [self assertString: output hasTrait: NSBoldFontMask atIndex: 2 message: @"c"];
  [self assertString: output hasTrait: NSUnboldFontMask atIndex: 3 message: @"d"];
  [self assertString: output hasTrait: NSBoldFontMask atIndex: 4 message: @"e"];
  
  output = [queue processAttributedString: input];
  [self assertString: output hasTrait: NSBoldFontMask atIndex: 0 message: @"a2"];
}

- (void) testUnderline
{
  NSAttributedString *input = [self makeString: @"a\x1B[4mb\x1B[24mc\x1B[4md\x1B[0me"];  
  NSAttributedString *output = [queue processAttributedString: input];
  
  [self assertString: output hasValue: nil forAttribute: NSUnderlineStyleAttributeName atIndex: 0 message: @"a"];
  [self assertString: output hasValue: [NSNumber numberWithInt: NSSingleUnderlineStyle] forAttribute: NSUnderlineStyleAttributeName atIndex: 1 message: @"b"];
  [self assertString: output hasValue: [NSNumber numberWithInt: NSNoUnderlineStyle] forAttribute: NSUnderlineStyleAttributeName atIndex: 2 message: @"c"];
  [self assertString: output hasValue: [NSNumber numberWithInt: NSSingleUnderlineStyle] forAttribute: NSUnderlineStyleAttributeName atIndex: 3 message: @"d"];
  [self assertString: output hasValue: [NSNumber numberWithInt: NSNoUnderlineStyle] forAttribute: NSUnderlineStyleAttributeName atIndex: 4 message: @"e"];  
}

- (void) testFormattingOverTwoLines
{
  NSAttributedString *input1 = [self makeString: @"a\x1B["];  
  NSAttributedString *input2 = [self makeString: @"4mb"];  
  [queue processAttributedString: input1];
  
  NSAttributedString *output = [queue processAttributedString: input2];
   
  [self assertString: output hasValue: [NSNumber numberWithInt: NSSingleUnderlineStyle] forAttribute: NSUnderlineStyleAttributeName atIndex: 0 message: @"b"];
}

- (void) testRetainsPartialCode
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  [self assertInput: @"\x1B[" hasOutput: @""];
  [pool release];
  [self assertInput: @"m" hasOutput: @""];
}

@end

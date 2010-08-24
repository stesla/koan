//
// J3ANSIFormattingFilterTests.m
//
// Copyright (c) 2010 3James Software.
//

#import "J3ANSIFormattingFilterTests.h"
#import "J3ANSIFormattingFilter.h"
#import "J3Formatter.h"
#import "NSFont (Traits).h"

@interface J3ANSIFormattingFilterTests (Private)

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
- (void) assertString: (NSAttributedString *) string
           hasntTrait: (NSFontTraitMask) trait
              atIndex: (int) characterIndex
              message: (NSString *) message;

@end

#pragma mark -

@implementation J3ANSIFormattingFilterTests (Private)

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
  NSDictionary *attributes = [string attributesAtIndex: characterIndex effectiveRange: NULL];
  
  [self assert: [attributes valueForKey: attribute] equals: value message: message];
}

- (void) assertString: (NSAttributedString *) string
             hasTrait: (NSFontTraitMask) trait
              atIndex: (int) characterIndex
              message: (NSString *) message
{
  NSFont *font = [string attribute: NSFontAttributeName atIndex: characterIndex effectiveRange: NULL];
  
  [self assertTrue: [font hasTrait: trait] message: message];
}

- (void) assertString: (NSAttributedString *) string
           hasntTrait: (NSFontTraitMask) trait
              atIndex: (int) characterIndex
              message: (NSString *) message
{
  NSFont *font = [string attribute: NSFontAttributeName atIndex: characterIndex effectiveRange: NULL];
  
  [self assertFalse: [font hasTrait: trait] message: message];
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

- (void) testCompoundCode
{
  [self assertInput: @"F\x1B[0;1;3;32;45moo"
          hasOutput: @"Foo"];
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
  NSAttributedString *input = [self constructAttributedStringForString: @"a\x1B[36mbc\x1B[35md\x1B[39me"];
  NSAttributedString *output = [queue processAttributedString: input];
  
  [self assertString: output hasValue: nil forAttribute: NSForegroundColorAttributeName atIndex: 0 message: @"a"];
  [self assertString: output hasValue: [NSColor cyanColor] forAttribute: NSForegroundColorAttributeName atIndex: 1 message: @"b"];
  [self assertString: output hasValue: [NSColor cyanColor] forAttribute: NSForegroundColorAttributeName atIndex: 2 message: @"c"];
  [self assertString: output hasValue: [NSColor magentaColor] forAttribute: NSForegroundColorAttributeName atIndex: 3 message: @"d"];
  [self assertString: output hasValue: [J3Formatter testingForeground] forAttribute: NSForegroundColorAttributeName atIndex: 4 message: @"e"];
}

- (void) testStandardForegroundColors
{
  NSAttributedString *input = [self constructAttributedStringForString: @"\x1B[30ma\x1B[31mb\x1B[32mc\x1B[33md\x1B[34me\x1B[35mf\x1B[36mg\x1B[37mh"];
  NSAttributedString *output = [queue processAttributedString: input];
  
  [self assertString: output hasValue: [NSColor darkGrayColor] forAttribute: NSForegroundColorAttributeName atIndex: 0 message: @"a"];
  [self assertString: output hasValue: [NSColor redColor] forAttribute: NSForegroundColorAttributeName atIndex: 1 message: @"b"];
  [self assertString: output hasValue: [NSColor greenColor] forAttribute: NSForegroundColorAttributeName atIndex: 2 message: @"c"];
  [self assertString: output hasValue: [NSColor yellowColor] forAttribute: NSForegroundColorAttributeName atIndex: 3 message: @"d"];
  [self assertString: output hasValue: [NSColor blueColor] forAttribute: NSForegroundColorAttributeName atIndex: 4 message: @"e"];
  [self assertString: output hasValue: [NSColor magentaColor] forAttribute: NSForegroundColorAttributeName atIndex: 5 message: @"f"];
  [self assertString: output hasValue: [NSColor cyanColor] forAttribute: NSForegroundColorAttributeName atIndex: 6 message: @"g"];
  [self assertString: output hasValue: [NSColor whiteColor] forAttribute: NSForegroundColorAttributeName atIndex: 7 message: @"h"];
}

- (void) testXTerm256ForegroundColor
{
  for (unsigned i = 0; i < 16; i++)
  {
    NSAttributedString *input = [self constructAttributedStringForString: [NSString stringWithFormat: @"\x1B[38;5;%dm%d", i, i]];
    NSAttributedString *output = [queue processAttributedString: input];
    
    NSColor *targetColor;
    
    switch (i)
    {
      case J3ANSI256Black:
      case J3ANSI256BrightBlack:
        targetColor = [NSColor darkGrayColor];
        break;
        
      case J3ANSI256Red:
      case J3ANSI256BrightRed:
        targetColor = [NSColor redColor];
        break;
        
      case J3ANSI256Green:
      case J3ANSI256BrightGreen:
        targetColor = [NSColor greenColor];
        break;
        
      case J3ANSI256Yellow:
      case J3ANSI256BrightYellow:
        targetColor = [NSColor yellowColor];
        break;
        
      case J3ANSI256Blue:
      case J3ANSI256BrightBlue:
        targetColor = [NSColor blueColor];
        break;
        
      case J3ANSI256Magenta:
      case J3ANSI256BrightMagenta:
        targetColor = [NSColor magentaColor];
        break;
        
      case J3ANSI256Cyan:
      case J3ANSI256BrightCyan:
        targetColor = [NSColor cyanColor];
        break;
        
      case J3ANSI256White:
      case J3ANSI256BrightWhite:
        targetColor = [NSColor whiteColor];
    }
    
    [self assertString: output hasValue: targetColor forAttribute: NSForegroundColorAttributeName atIndex: 0 message: [NSString stringWithFormat: @"%d", i]];
  }
  
  for (unsigned i = 16; i < 232; i++)
  {
    NSAttributedString *input = [self constructAttributedStringForString: [NSString stringWithFormat: @"\x1B[38;5;%dm%d", i, i]];
    NSAttributedString *output = [queue processAttributedString: input];
    
    int adjustedValue = i - 16;
    int red = adjustedValue / 36;
    int green = (adjustedValue % 36) / 6;
    int blue = (adjustedValue % 36) % 6;
    
    NSColor *cubeColor = [NSColor colorWithCalibratedRed: 1. / 6. * red
                                                   green: 1. / 6. * green
                                                    blue: 1. / 6. * blue
                                                   alpha: 1.0];
    
    [self assertString: output hasValue: cubeColor forAttribute: NSForegroundColorAttributeName atIndex: 0 message: [NSString stringWithFormat: @"%d", i]];
  }
  
  for (unsigned i = 232; i < 256; i++)
  {
    NSAttributedString *input = [self constructAttributedStringForString: [NSString stringWithFormat: @"\x1B[38;5;%dm%d", i, i]];
    NSAttributedString *output = [queue processAttributedString: input];
    
    int adjustedValue = i - 231;
    
    NSColor *grayscaleColor = [NSColor colorWithCalibratedWhite: 1. / 25. * adjustedValue
                                                          alpha: 1.0];
    
    [self assertString: output hasValue: grayscaleColor forAttribute: NSForegroundColorAttributeName atIndex: 0 message: [NSString stringWithFormat: @"%d", i]];
  }
}

- (void) testBackgroundColor
{
  NSAttributedString *input = [self constructAttributedStringForString: @"a\x1B[46mbc\x1B[45md\x1B[49me"];
  NSAttributedString *output = [queue processAttributedString: input];
  
  [self assertString: output hasValue: nil forAttribute: NSBackgroundColorAttributeName atIndex: 0 message: @"a"];
  [self assertString: output hasValue: [NSColor cyanColor] forAttribute: NSBackgroundColorAttributeName atIndex: 1 message: @"b"];
  [self assertString: output hasValue: [NSColor cyanColor] forAttribute: NSBackgroundColorAttributeName atIndex: 2 message: @"c"];
  [self assertString: output hasValue: [NSColor magentaColor] forAttribute: NSBackgroundColorAttributeName atIndex: 3 message: @"d"];
  [self assertString: output hasValue: [J3Formatter testingBackground] forAttribute: NSBackgroundColorAttributeName atIndex: 4 message: @"e"];
}

- (void) testStandardBackgroundColors
{
  NSAttributedString *input = [self constructAttributedStringForString: @"\x1B[40ma\x1B[41mb\x1B[42mc\x1B[43md\x1B[44me\x1B[45mf\x1B[46mg\x1B[47mh"];
  NSAttributedString *output = [queue processAttributedString: input];
  
  [self assertString: output hasValue: [NSColor darkGrayColor] forAttribute: NSBackgroundColorAttributeName atIndex: 0 message: @"a"];
  [self assertString: output hasValue: [NSColor redColor] forAttribute: NSBackgroundColorAttributeName atIndex: 1 message: @"b"];
  [self assertString: output hasValue: [NSColor greenColor] forAttribute: NSBackgroundColorAttributeName atIndex: 2 message: @"c"];
  [self assertString: output hasValue: [NSColor yellowColor] forAttribute: NSBackgroundColorAttributeName atIndex: 3 message: @"d"];
  [self assertString: output hasValue: [NSColor blueColor] forAttribute: NSBackgroundColorAttributeName atIndex: 4 message: @"e"];
  [self assertString: output hasValue: [NSColor magentaColor] forAttribute: NSBackgroundColorAttributeName atIndex: 5 message: @"f"];
  [self assertString: output hasValue: [NSColor cyanColor] forAttribute: NSBackgroundColorAttributeName atIndex: 6 message: @"g"];
  [self assertString: output hasValue: [NSColor whiteColor] forAttribute: NSBackgroundColorAttributeName atIndex: 7 message: @"h"];
}

- (void) testXTerm256BackgroundColor
{
  for (unsigned i = 0; i < 16; i++)
  {
    NSAttributedString *input = [self constructAttributedStringForString: [NSString stringWithFormat: @"\x1B[48;5;%dm%d", i, i]];
    NSAttributedString *output = [queue processAttributedString: input];
    
    NSColor *targetColor;
    
    switch (i)
    {
      case J3ANSI256Black:
      case J3ANSI256BrightBlack:
        targetColor = [NSColor darkGrayColor];
        break;
        
      case J3ANSI256Red:
      case J3ANSI256BrightRed:
        targetColor = [NSColor redColor];
        break;
        
      case J3ANSI256Green:
      case J3ANSI256BrightGreen:
        targetColor = [NSColor greenColor];
        break;
        
      case J3ANSI256Yellow:
      case J3ANSI256BrightYellow:
        targetColor = [NSColor yellowColor];
        break;
        
      case J3ANSI256Blue:
      case J3ANSI256BrightBlue:
        targetColor = [NSColor blueColor];
        break;
        
      case J3ANSI256Magenta:
      case J3ANSI256BrightMagenta:
        targetColor = [NSColor magentaColor];
        break;
        
      case J3ANSI256Cyan:
      case J3ANSI256BrightCyan:
        targetColor = [NSColor cyanColor];
        break;
        
      case J3ANSI256White:
      case J3ANSI256BrightWhite:
        targetColor = [NSColor whiteColor];
    }
    
    [self assertString: output hasValue: targetColor forAttribute: NSBackgroundColorAttributeName atIndex: 0 message: [NSString stringWithFormat: @"%d", i]];
  }
  
  for (unsigned i = 16; i < 232; i++)
  {
    NSAttributedString *input = [self constructAttributedStringForString: [NSString stringWithFormat: @"\x1B[48;5;%dm%d", i, i]];
    NSAttributedString *output = [queue processAttributedString: input];
    
    int adjustedValue = i - 16;
    int red = adjustedValue / 36;
    int green = (adjustedValue % 36) / 6;
    int blue = (adjustedValue % 36) % 6;
    
    NSColor *cubeColor = [NSColor colorWithCalibratedRed: 1. / 6. * red
                                                   green: 1. / 6. * green
                                                    blue: 1. / 6. * blue
                                                   alpha: 1.0];
    
    [self assertString: output hasValue: cubeColor forAttribute: NSBackgroundColorAttributeName atIndex: 0 message: [NSString stringWithFormat: @"%d", i]];
  }
  
  for (unsigned i = 232; i < 256; i++)
  {
    NSAttributedString *input = [self constructAttributedStringForString: [NSString stringWithFormat: @"\x1B[48;5;%dm%d", i, i]];
    NSAttributedString *output = [queue processAttributedString: input];
    
    int adjustedValue = i - 231;
    
    NSColor *grayscaleColor = [NSColor colorWithCalibratedWhite: 1. / 25. * adjustedValue
                                                          alpha: 1.0];
    
    [self assertString: output hasValue: grayscaleColor forAttribute: NSBackgroundColorAttributeName atIndex: 0 message: [NSString stringWithFormat: @"%d", i]];
  }
}

- (void) testForegroundAndBackgroundColorAsCompoundCode
{
  NSAttributedString *input = [self constructAttributedStringForString: @"a\x1B[36;46mbc\x1B[45;35md\x1B[39;49me"];
  NSAttributedString *output = [queue processAttributedString: input];
  
  [self assertString: output hasValue: nil forAttribute: NSForegroundColorAttributeName atIndex: 0 message: @"a foreground"];
  [self assertString: output hasValue: nil forAttribute: NSBackgroundColorAttributeName atIndex: 0 message: @"a background"];
  [self assertString: output hasValue: [NSColor cyanColor] forAttribute: NSForegroundColorAttributeName atIndex: 1 message: @"b foreground"];
  [self assertString: output hasValue: [NSColor cyanColor] forAttribute: NSBackgroundColorAttributeName atIndex: 1 message: @"b background"];
  [self assertString: output hasValue: [NSColor cyanColor] forAttribute: NSForegroundColorAttributeName atIndex: 2 message: @"c foreground"];
  [self assertString: output hasValue: [NSColor cyanColor] forAttribute: NSBackgroundColorAttributeName atIndex: 2 message: @"c background"];
  [self assertString: output hasValue: [NSColor magentaColor] forAttribute: NSForegroundColorAttributeName atIndex: 3 message: @"d foreground"];
  [self assertString: output hasValue: [NSColor magentaColor] forAttribute: NSBackgroundColorAttributeName atIndex: 3 message: @"d background"];
  [self assertString: output hasValue: [J3Formatter testingForeground] forAttribute: NSForegroundColorAttributeName atIndex: 4 message: @"e foreground"];
  [self assertString: output hasValue: [J3Formatter testingBackground] forAttribute: NSBackgroundColorAttributeName atIndex: 4 message: @"e background"];
}

- (void) testResetDisplayMode
{
  NSAttributedString *input = [self constructAttributedStringForString: @"a\x1B[36m\x1B[46mb\x1B[0mc"];
  NSAttributedString *output = [queue processAttributedString: input];
  
  [self assertString: output hasValue: [NSColor cyanColor] forAttribute: NSBackgroundColorAttributeName atIndex: 1 message: @"b background"];
  [self assertString: output hasValue: [NSColor cyanColor] forAttribute: NSForegroundColorAttributeName atIndex: 1 message: @"b foreground"];
  [self assertString: output hasValue: [J3Formatter testingBackground] forAttribute: NSBackgroundColorAttributeName atIndex: 2 message: @"c background"];  
  [self assertString: output hasValue: [J3Formatter testingForeground] forAttribute: NSForegroundColorAttributeName atIndex: 2 message: @"c foreground"];  
}

- (void) testCompoundSetThenResetDisplayMode
{
  NSAttributedString *input = [self constructAttributedStringForString: @"a\x1B[36;46mb\x1B[0mc"];
  NSAttributedString *output = [queue processAttributedString: input];
  
  [self assertString: output hasValue: [NSColor cyanColor] forAttribute: NSBackgroundColorAttributeName atIndex: 1 message: @"b background"];
  [self assertString: output hasValue: [NSColor cyanColor] forAttribute: NSForegroundColorAttributeName atIndex: 1 message: @"b foreground"];
  [self assertString: output hasValue: [J3Formatter testingBackground] forAttribute: NSBackgroundColorAttributeName atIndex: 2 message: @"c background"];  
  [self assertString: output hasValue: [J3Formatter testingForeground] forAttribute: NSForegroundColorAttributeName atIndex: 2 message: @"c foreground"];  
}

- (void) testShortFormOfResetDisplayMode
{
  NSAttributedString *input = [self constructAttributedStringForString: @"a\x1B[36m\x1B[46mb\x1B[mc"];
  NSAttributedString *output = [queue processAttributedString: input];
  
  [self assertString: output hasValue: [NSColor cyanColor] forAttribute: NSBackgroundColorAttributeName atIndex: 1 message: @"b background"];
  [self assertString: output hasValue: [NSColor cyanColor] forAttribute: NSForegroundColorAttributeName atIndex: 1 message: @"b foreground"];
  [self assertString: output hasValue: [J3Formatter testingBackground] forAttribute: NSBackgroundColorAttributeName atIndex: 2 message: @"c background"];  
  [self assertString: output hasValue: [J3Formatter testingForeground] forAttribute: NSForegroundColorAttributeName atIndex: 2 message: @"c foreground"]; 
}

- (void) testPersistColorsBetweenLines
{
  NSAttributedString *firstInput = [self constructAttributedStringForString: @"a\x1B[36mb"];
  NSAttributedString *secondInput = [self constructAttributedStringForString: @"c"];
  NSAttributedString *output;
  
  [queue processAttributedString: firstInput];
  output = [queue processAttributedString: secondInput];
  
  [self assertString: output hasValue: [NSColor cyanColor] forAttribute: NSForegroundColorAttributeName atIndex: 0 message: @"c"];
}

- (void) testBold
{
  NSAttributedString *input = [self constructAttributedStringForString: @"a\x1B[1mb\x1B[22mc\x1B[1md\x1B[0me\x1B[1mf\x1B[mg"];
  NSAttributedString *output = [queue processAttributedString: input];

  [self assertString: output hasntTrait: NSBoldFontMask atIndex: 0 message: @"a"];
  [self assertString: output hasTrait: NSBoldFontMask atIndex: 1 message: @"b"];
  [self assertString: output hasntTrait: NSBoldFontMask atIndex: 2 message: @"c"];
  [self assertString: output hasTrait: NSBoldFontMask atIndex: 3 message: @"d"];
  [self assertString: output hasntTrait: NSBoldFontMask atIndex: 4 message: @"e"];
  [self assertString: output hasTrait: NSBoldFontMask atIndex: 5 message: @"f"];
  [self assertString: output hasntTrait: NSBoldFontMask atIndex: 6 message: @"g"];
}
- (void) testBoldWithBoldAlreadyOn
{
  NSMutableAttributedString *input = [self constructAttributedStringForString: @"a\x1B[1mb\x1B[22mc\x1B[1md\x1B[0me\x1B[1mf\x1B[mg"];
  NSAttributedString *output;
  NSFont *boldFont = [[J3Formatter testingFont] fontWithTrait: NSBoldFontMask];
  
  [queue clearFilters];
  [queue addFilter: [J3ANSIFormattingFilter filterWithFormatter: [J3Formatter formatterWithForegroundColor: [J3Formatter testingForeground] backgroundColor: [J3Formatter testingBackground] font: boldFont]]];

  output = [queue processAttributedString: input];
  [self assertString: output hasTrait: NSBoldFontMask atIndex: 0 message: @"a"];
  [self assertString: output hasntTrait: NSBoldFontMask atIndex: 1 message: @"b"];
  [self assertString: output hasTrait: NSBoldFontMask atIndex: 2 message: @"c"];
  [self assertString: output hasntTrait: NSBoldFontMask atIndex: 3 message: @"d"];
  [self assertString: output hasTrait: NSBoldFontMask atIndex: 4 message: @"e"];
  [self assertString: output hasntTrait: NSBoldFontMask atIndex: 5 message: @"f"];
  [self assertString: output hasTrait: NSBoldFontMask atIndex: 6 message: @"g"];
  
  output = [queue processAttributedString: input];
  [self assertString: output hasTrait: NSBoldFontMask atIndex: 0 message: @"a2"];
}

- (void) testUnderline
{
  NSAttributedString *input = [self constructAttributedStringForString: @"a\x1B[4mb\x1B[24mc\x1B[4md\x1B[0me\x1B[4mf\x1B[mg"];  
  NSAttributedString *output = [queue processAttributedString: input];
  
  [self assertString: output
            hasValue: nil
        forAttribute: NSUnderlineStyleAttributeName
             atIndex: 0
             message: @"a"];
  
  [self assertString: output
            hasValue: [NSNumber numberWithInt: NSSingleUnderlineStyle]
        forAttribute: NSUnderlineStyleAttributeName
             atIndex: 1
             message: @"b"];
  
  [self assertString: output
            hasValue: [NSNumber numberWithInt: NSNoUnderlineStyle]
        forAttribute: NSUnderlineStyleAttributeName
             atIndex: 2
             message: @"c"];
  
  [self assertString: output
            hasValue: [NSNumber numberWithInt: NSSingleUnderlineStyle]
        forAttribute: NSUnderlineStyleAttributeName
             atIndex: 3
             message: @"d"];
  
  [self assertString: output
            hasValue: [NSNumber numberWithInt: NSNoUnderlineStyle]
        forAttribute: NSUnderlineStyleAttributeName
             atIndex: 4
             message: @"e"];
  
  [self assertString: output
            hasValue: [NSNumber numberWithInt: NSSingleUnderlineStyle]
        forAttribute: NSUnderlineStyleAttributeName
             atIndex: 5
             message: @"f"];
  
  [self assertString: output
            hasValue: [NSNumber numberWithInt: NSNoUnderlineStyle]
        forAttribute: NSUnderlineStyleAttributeName
             atIndex: 6
             message: @"g"];
}

- (void) testFormattingOverTwoLines
{
  NSAttributedString *input1 = [self constructAttributedStringForString: @"a\x1B["];  
  NSAttributedString *input2 = [self constructAttributedStringForString: @"4mb"];  
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

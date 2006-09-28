//
// J3AnsiFormattingFilterTests.m
//
// Copyright (c) 2004, 2005 3James Software
//

#import "J3AnsiFormattingFilterTests.h"
#import "J3AnsiFormattingFilter.h"

@interface J3AnsiFormattingFilterTests (Private)
- (void) assertInput:(NSString *)input hasOutput:(NSString *)output;
- (void) assertInput:(NSString *)input hasOutput:(NSString *)output
             message:(NSString *)message;
- (void) assertFinalCharacter:(unsigned char)finalChar;
- (void) assertString:(NSAttributedString *)string hasValue:(id)value forAttribute:(NSString *)attribute atIndex:(int)index message:(NSString *)message;
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
  NSAttributedString *attributedInput = 
    [NSAttributedString attributedStringWithString:input];
  NSAttributedString *attributedExpectedOutput = 
    [NSAttributedString attributedStringWithString:output];
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

- (void) testOnlyWhitespaceBeforeCode
{
  [self assertInput:@" \x1B[1m"
          hasOutput:@" "];
}

- (void) testForegroundColor;
{
  NSAttributedString * input = [NSAttributedString attributedStringWithString:@"a\x1B[36mbc\x1B[35md\x1B[39me"];
  NSAttributedString * output = [queue processAttributedString:input];
  
  [self assertString:output hasValue:nil forAttribute:NSForegroundColorAttributeName atIndex:0 message:@"a"];
  [self assertString:output hasValue:[NSColor cyanColor] forAttribute:NSForegroundColorAttributeName atIndex:1 message:@"b"];
  [self assertString:output hasValue:[NSColor cyanColor] forAttribute:NSForegroundColorAttributeName atIndex:2 message:@"c"];
  [self assertString:output hasValue:[NSColor magentaColor] forAttribute:NSForegroundColorAttributeName atIndex:3 message:@"d"];
  [self assertString:output hasValue:nil forAttribute:NSForegroundColorAttributeName atIndex:4 message:@"e"];
}

- (void) testBackgroundColor;
{
  NSAttributedString * input = [NSAttributedString attributedStringWithString:@"a\x1B[46mbc\x1B[45md\x1B[49me"];
  NSAttributedString * output = [queue processAttributedString:input];
  
  [self assertString:output hasValue:nil forAttribute:NSForegroundColorAttributeName atIndex:0 message:@"a"];
  [self assertString:output hasValue:[NSColor cyanColor] forAttribute:NSBackgroundColorAttributeName atIndex:1 message:@"b"];
  [self assertString:output hasValue:[NSColor cyanColor] forAttribute:NSBackgroundColorAttributeName atIndex:2 message:@"c"];
  [self assertString:output hasValue:[NSColor magentaColor] forAttribute:NSBackgroundColorAttributeName atIndex:3 message:@"d"];
  [self assertString:output hasValue:nil forAttribute:NSBackgroundColorAttributeName atIndex:4 message:@"e"];
}

- (void) testReset;
{
  NSAttributedString * input = [NSAttributedString attributedStringWithString:@"a\x1B[36m\x1B[46mb\x1B[0mc"];
  NSAttributedString * output = [queue processAttributedString:input];
  
  [self assertString:output hasValue:[NSColor cyanColor] forAttribute:NSBackgroundColorAttributeName atIndex:1 message:@"b background"];
  [self assertString:output hasValue:[NSColor cyanColor] forAttribute:NSForegroundColorAttributeName atIndex:1 message:@"b foreground"];
  [self assertString:output hasValue:nil forAttribute:NSBackgroundColorAttributeName atIndex:2 message:@"c background"];  
  [self assertString:output hasValue:nil forAttribute:NSForegroundColorAttributeName atIndex:2 message:@"c foreground"];  
}

@end

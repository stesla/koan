//
// J3ANSIRemovingFilterTests.m
//
// Copyright (C) 2004, 2005 3James Software
//

#import "J3ANSIRemovingFilterTests.h"
#import "J3ANSIRemovingFilter.h"

@interface J3ANSIRemovingFilterTests (Private)
- (void) assertInput:(NSString *)input hasOutput:(NSString *)output;
- (void) assertInput:(NSString *)input hasOutput:(NSString *)output
             message:(NSString *)message;
- (void) assertFinalCharacter:(unsigned char)finalChar;
@end

#pragma mark -

@implementation J3ANSIRemovingFilterTests (Private)

- (void) assertInput:(NSString *)input hasOutput:(NSString *)output
{
  [self assertInput:input hasOutput:output message:nil];
}

- (void) assertInput:(NSString *)input hasOutput:(NSString *)output
             message:(NSString *)message
{
  NSAttributedString *attributedInput = 
    [NSAttributedString attributedStringWithString:input];
  NSAttributedString *attributedOutput = 
    [NSAttributedString attributedStringWithString:output];
  [self assert:[queue processAttributedString:attributedInput] 
        equals:attributedOutput
       message:message];  
}

- (void) assertFinalCharacter:(unsigned char)finalChar
{
  [self assertInput:[NSString stringWithFormat:@"F\x1B[%coo", finalChar]
          hasOutput:@"Foo"
            message:[NSString stringWithFormat:@"[%X]", finalChar]];
}
@end

#pragma mark -

@implementation J3ANSIRemovingFilterTests

- (void) setUp
{
  queue = [[J3FilterQueue alloc] init];
  [queue addFilter:[J3ANSIRemovingFilter filter]];
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

@end

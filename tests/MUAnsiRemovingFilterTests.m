//
// MUAnsiRemovingFilterTests.m
//
// Copyright (C) 2004 Tyler Berry and Samuel Tesla
//
// Koan is free software; you can redistribute it and/or modify it under the
// terms of the GNU General Public License as published by the Free Software
// Foundation; either version 2 of the License, or (at your option) any later
// version.
//
// Koan is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// Koan; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
// Suite 330, Boston, MA 02111-1307 USA
//

#import "MUAnsiRemovingFilterTests.h"
#import "MUAnsiRemovingFilter.h"

@interface MUAnsiRemovingFilterTests (Private)
- (void) assertInput:(NSString *)input hasOutput:(NSString *)output;
- (void) assertInput:(NSString *)input hasOutput:(NSString *)output
             message:(NSString *)message;
- (void) assertFinalCharacter:(unsigned char)finalChar;
@end

@implementation MUAnsiRemovingFilterTests (Private)

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
  [self assert:[_queue processAttributedString:attributedInput] 
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

@implementation MUAnsiRemovingFilterTests

- (void) setUp
{
  _queue = [[MUFilterQueue alloc] init];
  [_queue addFilter:[MUAnsiRemovingFilter filter]];
}

- (void) tearDown
{
  [_queue release];
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

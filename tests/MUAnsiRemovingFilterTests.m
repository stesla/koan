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
- (void) assertInput:(NSAttributedString *)input hasOutput:(NSAttributedString *)output;
- (void) assertInput:(NSAttributedString *)input hasOutput:(NSAttributedString *)output
             message:(NSString *)message;
@end

@implementation MUAnsiRemovingFilterTests (Private)

- (void) assertInput:(NSAttributedString *)input hasOutput:(NSAttributedString *)output
{
  [self assert:[_queue processAttributedString:input] equals:output];
}

- (void) assertInput:(NSAttributedString *)input hasOutput:(NSAttributedString *)output
             message:(NSString *)message
{
  [self assert:[_queue processAttributedString:input] equals:output
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
  [self assertInput:[NSAttributedString attributedStringWithString:@"Foo"]
          hasOutput:[NSAttributedString attributedStringWithString:@"Foo"]];
}

- (void) testSingleCharacter
{
  [self assertInput:[NSAttributedString attributedStringWithString:@"Q"]
          hasOutput:[NSAttributedString attributedStringWithString:@"Q"]];
}

- (void) testBasicCode
{
  [self assertInput:[NSAttributedString attributedStringWithString:@"F\033[moo"]
          hasOutput:[NSAttributedString attributedStringWithString:@"Foo"]
            message:@"One"];
  [self assertInput:[NSAttributedString attributedStringWithString:@"F\033[3moo"]
          hasOutput:[NSAttributedString attributedStringWithString:@"Foo"]
            message:@"Two"];
  [self assertInput:[NSAttributedString attributedStringWithString:@"F\033[36moo"]
          hasOutput:[NSAttributedString attributedStringWithString:@"Foo"]
            message:@"Three"];
}

- (void) testTwoCodes
{
  [self assertInput:[NSAttributedString attributedStringWithString:@"F\033[36moa\033[3mob"]
          hasOutput:[NSAttributedString attributedStringWithString:@"Foaob"]];
}

- (void) testNewLine
{
  [self assertInput:[NSAttributedString attributedStringWithString:@"Foo\n"]
          hasOutput:[NSAttributedString attributedStringWithString:@"Foo\n"]];
}

- (void) testNewLineOnly
{
  [self assertInput:[NSAttributedString attributedStringWithString:@"\n"]
          hasOutput:[NSAttributedString attributedStringWithString:@"\n"]];
}

- (void) testCodeAtEndOfLine
{
  [self assertInput:[NSAttributedString attributedStringWithString:@"Foo\033[36m\n"]
          hasOutput:[NSAttributedString attributedStringWithString:@"Foo\n"]];
}

- (void) testCodeAtBeginningOfString
{
  [self assertInput:[NSAttributedString attributedStringWithString:@"\033[36mFoo"]
          hasOutput:[NSAttributedString attributedStringWithString:@"Foo"]];
}

- (void) testCodeAtEndOfString
{
  [self assertInput:[NSAttributedString attributedStringWithString:@"Foo\033[36m"]
          hasOutput:[NSAttributedString attributedStringWithString:@"Foo"]];
}

- (void) testEmptyString
{
  [self assertInput:[NSAttributedString attributedStringWithString:@""]
          hasOutput:[NSAttributedString attributedStringWithString:@""]];
}

- (void) testOnlyCode
{
  [self assertInput:[NSAttributedString attributedStringWithString:@"\033[36m"]
          hasOutput:[NSAttributedString attributedStringWithString:@""]];
}

- (void) testLongString
{
  NSString *longString = 
    @"        #@@N         (@@)     (@@@)        J@@@@F      @@@@@@@L";
  [self assertInput:[NSAttributedString attributedStringWithString:longString]
          hasOutput:[NSAttributedString attributedStringWithString:longString]];
}

@end

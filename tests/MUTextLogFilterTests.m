//
// MUTextLogFilterTests.m
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

#import "MUTextLogFilterTests.h"
#import "MUTextLogFilter.h"

@interface MUTextLogFilterTests (Private)
- (void) assertFilter:(id)object;
- (void) assertFilterString:(NSString *)string;
- (void) assertLoggedOutput:(NSString *)string;
@end

@implementation MUTextLogFilterTests (Private)

- (void) assertFilter:(id)object
{
  [self assert:[_filter filter:object] equals:object message:nil];
}

- (void) assertFilterString:(NSString *)string
{
  [self assertFilter:[NSAttributedString attributedStringWithString:string]];
}

- (void) assertLoggedOutput:(NSString *)string
{
  NSString *outputString = [NSString stringWithCString:(const char *)_outputBuffer];
  
  [self assert:outputString equals:string];
}

@end

@implementation MUTextLogFilterTests

- (void) setUp
{
  memset (_outputBuffer, 0, MUTextLogTestBufferMax);
  NSOutputStream *output = [NSOutputStream outputStreamToBuffer:_outputBuffer
                                                       capacity:MUTextLogTestBufferMax];
  [output open];
  
  _filter = [[MUTextLogFilter alloc] initWithOutputStream:output];
}

- (void) tearDown
{
  [_filter release];
}

- (void) testSimpleString
{
  [self assertFilterString:@"Foo"];
  [self assertLoggedOutput:@"Foo"];
}

- (void) testColorString
{
  NSMutableAttributedString *string = [NSMutableAttributedString attributedStringWithString:@"Foo"];
  [string addAttribute:NSForegroundColorAttributeName
                 value:[NSColor redColor]
                 range:NSMakeRange (0, [string length])];
  
  [self assertFilter:string];
  [self assertLoggedOutput:@"Foo"];
}

- (void) testFontString
{
  NSMutableAttributedString *string = [NSMutableAttributedString attributedStringWithString:@"Foo"];
  [string addAttribute:NSFontAttributeName
                 value:[NSFont fontWithName:@"Monaco" size:10.0]
                 range:NSMakeRange (0, [string length])];
  
  [self assertFilter:string];
  [self assertLoggedOutput:@"Foo"];
}

- (void) testSimpleConcatenation
{
  [self assertFilterString:@"One"];
  [self assertFilterString:@" "];
  [self assertFilterString:@"Two"];
  [self assertLoggedOutput:@"One Two"];
}

- (void) testComplexConcatenation
{
  NSMutableAttributedString *one = [NSMutableAttributedString attributedStringWithString:@"One"];
  NSMutableAttributedString *two = [NSMutableAttributedString attributedStringWithString:@"Two"];

  [one addAttribute:NSForegroundColorAttributeName
              value:[NSColor redColor]
              range:NSMakeRange (0, [one length])];
  
  [two addAttribute:NSFontAttributeName
              value:[NSFont fontWithName:@"Monaco" size:10.0]
              range:NSMakeRange (0, [two length])];
  
  [self assertFilter:one];
  [self assertFilterString:@" "];
  [self assertFilter:two];
  [self assertLoggedOutput:@"One Two"];
}

@end
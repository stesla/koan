//
// MUInputFilterTests.m
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

#import "MUInputFilterTests.h"
#import "MUInputFilter.h"

@implementation MUInputFilterTests

- (NSAttributedString *) filter:(NSAttributedString *)string
{
  return string;
}

- (id <MUFilterChaining>) chaining
{
  return nil;
}

- (void) testFilter
{
  MUInputFilter *filter = [[MUInputFilter alloc] init];
  [filter setSuccessor:self];
  
  NSAttributedString *input = [NSAttributedString attributedStringWithString:@"Foo"];

  _output = [filter filter:input];
  
  [self assert:_output equals:input];
  [filter release];
}

@end

@implementation MUUpperInputFilter

- (NSAttributedString *) filter:(NSAttributedString *)string
{
  return [NSAttributedString attributedStringWithString:[[string string] uppercaseString]
                                             attributes:[string attributesAtIndex:0 effectiveRange:0]];
}

@end

@implementation MUInputFilterQueueTests

- (void) testFilter
{
  MUInputFilterQueue *queue = [[MUInputFilterQueue alloc] init];
  NSAttributedString *input = [NSAttributedString attributedStringWithString:@"Foo"];
  NSAttributedString *output = [queue processAttributedString:input];
  [self assert:output equals:input];
}

- (void) testQueue
{
  MUInputFilterQueue *queue = [[MUInputFilterQueue alloc] init];
  MUUpperInputFilter *filter = [[MUUpperInputFilter alloc] init];
  [queue addFilter:filter];
  
  NSAttributedString *input = [NSAttributedString attributedStringWithString:@"Foo"];
  NSAttributedString *output = [queue processAttributedString:input];
  [self assert:[output string] equals:@"FOO"];
  [queue release];
}

@end

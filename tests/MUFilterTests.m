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

#import "MUFilterTests.h"

@implementation MUFilterTests

- (void) testFilter
{
  MUFilter *filter = [MUFilter filter];
  NSAttributedString *input = [NSAttributedString attributedStringWithString:@"Foo"];

  NSAttributedString *output = [filter filter:input];
  
  [self assert:output equals:input];
}

@end

@implementation MUUpperCaseFilter

- (NSAttributedString *) filter:(NSAttributedString *)string
{
  return [NSAttributedString attributedStringWithString:[[string string] uppercaseString]
                                             attributes:[string attributesAtIndex:0 effectiveRange:0]];
}

@end

@implementation MUFilterQueueTests

- (void) testFilter
{
  MUFilterQueue *queue = [[MUFilterQueue alloc] init];
  NSAttributedString *input = [NSAttributedString attributedStringWithString:@"Foo"];
  NSAttributedString *output = [queue processAttributedString:input];
  [self assert:output equals:input];
}

- (void) testQueue
{
  MUFilterQueue *queue = [[MUFilterQueue alloc] init];
  MUUpperCaseFilter *filter = [[MUUpperCaseFilter alloc] init];
  [queue addFilter:filter];
  
  NSAttributedString *input = [NSAttributedString attributedStringWithString:@"Foo"];
  NSAttributedString *output = [queue processAttributedString:input];
  [self assert:[output string] equals:@"FOO"];
  [queue release];
}

@end

//
// MUInputFilter.m
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

#import "MUInputFilter.h"

@implementation MUInputFilter

+ (MUInputFilter *) filter
{
  return [[[MUInputFilter alloc] init] autorelease];
}

- (void) filter:(NSString *)string
{
  [[self successor] filter:string];
}

- (id <MUFilterChaining>) chaining
{
  return self;
}

- (void) setSuccessor:(id <MUFiltering>)successor;
{
  _successor = successor;
}

- (id <MUFiltering>) successor
{
  return _successor;
}

@end

@implementation MUInputFilterQueue

- (id) init
{
  if (self = [super init])
  {
    _head = [[MUInputFilter alloc] init];
    _tail = _head;
    [_tail setSuccessor:self];
    _outputString = nil;
  }
  return self;
}

- (void) dealloc
{
  id <MUFilterChaining> curr = _head;
  id <MUFiltering> next = nil; 
  do
  {
    next = [curr successor];
    [(id)curr release];
    curr = [next chaining];
  }
  while (curr);
}

- (NSString *) processString:(NSString *)string
{
  [_head filter:string];
  return _outputString;
}

- (void) addFilter:(id <MUFiltering, MUFilterChaining>)filter
{
  [(id)filter retain];
  [_tail setSuccessor:filter];
  _tail = filter;
  [_tail setSuccessor:self];
}

- (void) filter:(NSString *)string
{
  _outputString = [string copy];
  [_outputString retain];
}

- (id <MUFilterChaining>) chaining
{
  return nil;
}

@end

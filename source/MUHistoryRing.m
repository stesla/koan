//
// MUHistoryRing.m
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

#import "MUHistoryRing.h"

@implementation MUHistoryRing

- (id) init
{
  if (self = [super init])
  {
    _ring = [[NSMutableArray alloc] init];
    _cursor = -1;
  }
  return self;
}

- (void) dealloc
{
  [_ring release];
  [super dealloc];
}

- (void) saveString:(NSString *)string
{
  if (_cursor >= 0 && _cursor < [_ring count])
    [_ring removeObjectAtIndex:_cursor];
  [_ring addObject:string];
  [_buffer release];
  _buffer = nil;
  _cursor = -1;
}

- (void) updateString:(NSString *)string
{
  if (_cursor == -1)
  {
    NSString *copy = [string copy];
    [_buffer release];
    _buffer = copy;
  }
  else
    [_ring replaceObjectAtIndex:_cursor withObject:string];
}

- (NSString *) nextString
{
  _cursor++;
  
  if (_cursor >= [_ring count] || _cursor < -1)
  {
    _cursor = -1;
    return _buffer == nil ? @"" : _buffer;
  }
  else
  {
    return [_ring objectAtIndex:_cursor];
  }
}

- (NSString *) previousString
{
  _cursor--;
  
  if (_cursor == -2)
    _cursor = [_ring count] - 1;
  else if (_cursor >= [_ring count] || _cursor < -2)
    _cursor = -1;
  
  if (_cursor == -1)
    return _buffer == nil ? @"" : _buffer;
  else
    return [_ring objectAtIndex:_cursor];
}

@end
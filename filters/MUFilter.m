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

#import "MUFilter.h"

@implementation MUFilter

+ (MUFilter *) filter
{
  return [[[MUFilter alloc] init] autorelease];
}

- (NSAttributedString *) filter:(NSAttributedString *)string
{
  return string;
}

@end

@implementation MUFilterQueue

- (id) init
{
  if (self = [super init])
  {
    _filters = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void) dealloc
{
  [_filters release];
}

- (NSAttributedString *) processAttributedString:(NSAttributedString *)string
{
  NSAttributedString *returnString = string;
  
  id <MUFiltering> filter = nil;
  int i;
  for (i = 0; i < [_filters count]; i++)
  {
    filter = (id <MUFiltering>) [_filters objectAtIndex:i];
    returnString = [filter filter:returnString];
  }
  return returnString;
}

- (void) addFilter:(id <MUFiltering>)filter
{
  [_filters addObject:filter];
}

@end

//
// MUHistoryRingTests.m
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

#import "MUHistoryRingTests.h"

@implementation MUHistoryRingTests

- (void) setUp
{
  _ring = [[MUHistoryRing alloc] init];
}

- (void) tearDown
{
  [_ring release];
}

- (void) testSinglePrevious
{
  [_ring saveString:@"Foo"];
  
  [self assert:[_ring previousString] equals:@"Foo"];
}

- (void) testMultiplePrevious
{
  [_ring saveString:@"Foo"];
  [_ring saveString:@"Bar"];
  [_ring saveString:@"Baz"];
  
  [self assert:[_ring previousString] equals:@"Baz"];
  [self assert:[_ring previousString] equals:@"Bar"];
  [self assert:[_ring previousString] equals:@"Foo"];
}

- (void) testFullCirclePrevious
{
  [_ring saveString:@"Foo"];
  
  [self assert:[_ring previousString] equals:@"Foo"];
  [self assert:[_ring previousString] equals:@""];
}

- (void) testSingleNext
{
  [_ring saveString:@"Foo"];
  
  [self assert:[_ring nextString] equals:@"Foo"];
}

- (void) testMultipleNext
{
  [_ring saveString:@"Foo"];
  [_ring saveString:@"Bar"];
  [_ring saveString:@"Baz"];
  
  [self assert:[_ring nextString] equals:@"Foo"];
  [self assert:[_ring nextString] equals:@"Bar"];
  [self assert:[_ring nextString] equals:@"Baz"];
}

- (void) testFullCircleNext
{
  [_ring saveString:@"Foo"];
  
  [self assert:[_ring nextString] equals:@"Foo"];
  [self assert:[_ring nextString] equals:@""];
}

- (void) testBothWays
{
  [_ring saveString:@"Foo"];
  [_ring saveString:@"Bar"];
  [_ring saveString:@"Baz"];
  
  [self assert:[_ring previousString] equals:@"Baz"];
  [self assert:[_ring previousString] equals:@"Bar"];
  [self assert:[_ring nextString] equals:@"Baz"];
  [self assert:[_ring nextString] equals:@""];
  [self assert:[_ring nextString] equals:@"Foo"];
  [self assert:[_ring nextString] equals:@"Bar"];
  [self assert:[_ring previousString] equals:@"Foo"];
  [self assert:[_ring previousString] equals:@""];
}

- (void) testUpdateMiddle
{
  [_ring saveString:@"Foo"];
  [_ring saveString:@"Bar"];
  [_ring saveString:@"Baz"];

  [self assert:[_ring previousString] equals:@"Baz"];
  [self assert:[_ring previousString] equals:@"Bar"];
  
  [_ring updateString:@"Bar Two"];
  
  [self assert:[_ring previousString] equals:@"Foo"];
  [self assert:[_ring previousString] equals:@""];
  [self assert:[_ring previousString] equals:@"Baz"];
  [self assert:[_ring previousString] equals:@"Bar Two"];
}

- (void) testUpdateBuffer
{
  [_ring saveString:@"Foo"];
  [_ring saveString:@"Bar"];
  
  [self assert:[_ring nextString] equals:@"Foo"];
  [self assert:[_ring nextString] equals:@"Bar"];
  [self assert:[_ring nextString] equals:@""];
  
  [_ring updateString:@"Temporary"];
  
  [self assert:[_ring nextString] equals:@"Foo"];
  [self assert:[_ring nextString] equals:@"Bar"];
  [self assert:[_ring nextString] equals:@"Temporary"];
  
  [_ring saveString:@"Something entirely different"];
  
  [self assert:[_ring previousString] equals:@"Something entirely different"];
  [self assert:[_ring previousString] equals:@"Bar"];
  [self assert:[_ring previousString] equals:@"Foo"];
  [self assert:[_ring previousString] equals:@""];
}

@end
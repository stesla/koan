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

@interface MUHistoryRingTests (Private)
- (void) assertPrevious:(NSString *)expected;
- (void) assertNext:(NSString *)expected;
@end

@implementation MUHistoryRingTests (Private)

- (void) assertPrevious:(NSString *)expected
{
  [self assert:[_ring previousString] equals:expected];
}

- (void) assertNext:(NSString *)expected
{
  [self assert:[_ring nextString] equals:expected];
}

@end

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
  
  [self assertPrevious:@"Foo"];
}

- (void) testMultiplePrevious
{
  [_ring saveString:@"Foo"];
  [_ring saveString:@"Bar"];
  [_ring saveString:@"Baz"];

  [self assertPrevious:@"Baz"];
  [self assertPrevious:@"Bar"];
  [self assertPrevious:@"Foo"];
}

- (void) testFullCirclePrevious
{
  [_ring saveString:@"Foo"];
  
  [self assertPrevious:@"Foo"];
  [self assertPrevious:@""];
}

- (void) testSingleNext
{
  [_ring saveString:@"Foo"];
  
  [self assertNext:@"Foo"];
}

- (void) testMultipleNext
{
  [_ring saveString:@"Foo"];
  [_ring saveString:@"Bar"];
  [_ring saveString:@"Baz"];
  
  [self assertNext:@"Foo"];
  [self assertNext:@"Bar"];
  [self assertNext:@"Baz"];
}

- (void) testFullCircleNext
{
  [_ring saveString:@"Foo"];
  
  [self assertNext:@"Foo"];
  [self assertNext:@""];
}

- (void) testBothWays
{
  [_ring saveString:@"Foo"];
  [_ring saveString:@"Bar"];
  [_ring saveString:@"Baz"];
  
  [self assertPrevious:@"Baz"];
  [self assertPrevious:@"Bar"];
  [self assertNext:@"Baz"];
  [self assertNext:@""];
  [self assertNext:@"Foo"];
  [self assertNext:@"Bar"];
  [self assertPrevious:@"Foo"];
  [self assertPrevious:@""];
}

- (void) testUpdateMiddle
{
  [_ring saveString:@"Foo"];
  [_ring saveString:@"Bar"];
  [_ring saveString:@"Baz"];

  [self assertPrevious:@"Baz"];
  [self assertPrevious:@"Bar"];
  
  [_ring updateString:@"Bar Two"];
  
  [self assertPrevious:@"Foo"];
  [self assertPrevious:@""];
  [self assertPrevious:@"Baz"];
  [self assertPrevious:@"Bar Two"];
}

- (void) testSaveReordering
{
  [_ring saveString:@"Foo"];
  [_ring saveString:@"Bar"];
  [_ring saveString:@"Baz"];
  
  [self assertNext:@"Foo"];
  [self assertNext:@"Bar"];
  
  [_ring saveString:@"Bar Two"];
  
  [self assertNext:@"Foo"];
  [self assertNext:@"Baz"];
  [self assertNext:@"Bar Two"];
  [self assertNext:@""];
}

- (void) testUpdateBuffer
{
  [_ring saveString:@"Foo"];
  [_ring saveString:@"Bar"];
  
  [self assertNext:@"Foo"];
  [self assertNext:@"Bar"];
  [self assertNext:@""];
  
  [_ring updateString:@"Temporary"];
  
  [self assertNext:@"Foo"];
  [self assertNext:@"Bar"];
  [self assertNext:@"Temporary"];
  
  [_ring saveString:@"Something entirely different"];
  
  [self assertPrevious:@"Something entirely different"];
  [self assertPrevious:@"Bar"];
  [self assertPrevious:@"Foo"];
  [self assertPrevious:@""];
}

@end
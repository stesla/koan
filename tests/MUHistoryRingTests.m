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
#import "MUHistoryRing.h"

@implementation MUHistoryRingTests

- (void) testSinglePrevious
{
  MUHistoryRing *ring = [[MUHistoryRing alloc] init];
  
  [ring saveString:@"Foo"];
  
  [self assert:[ring previousString] equals:@"Foo"];
}

- (void) testMultiplePrevious
{
  MUHistoryRing *ring = [[MUHistoryRing alloc] init];
  
  [ring saveString:@"Foo"];
  [ring saveString:@"Bar"];
  [ring saveString:@"Baz"];
  
  [self assert:[ring previousString] equals:@"Baz"];
  [self assert:[ring previousString] equals:@"Bar"];
  [self assert:[ring previousString] equals:@"Foo"];
}

- (void) testFullCirclePrevious
{
  MUHistoryRing *ring = [[MUHistoryRing alloc] init];
  
  [ring saveString:@"Foo"];
  
  [self assert:[ring previousString] equals:@"Foo"];
  [self assert:[ring previousString] equals:@""];
}

- (void) testSingleNext
{
  MUHistoryRing *ring = [[MUHistoryRing alloc] init];
  
  [ring saveString:@"Foo"];
  
  [self assert:[ring nextString] equals:@"Foo"];
}

- (void) testMultipleNext
{
  MUHistoryRing *ring = [[MUHistoryRing alloc] init];
  
  [ring saveString:@"Foo"];
  [ring saveString:@"Bar"];
  [ring saveString:@"Baz"];
  
  [self assert:[ring nextString] equals:@"Foo"];
  [self assert:[ring nextString] equals:@"Bar"];
  [self assert:[ring nextString] equals:@"Baz"];
}

- (void) testFullCircleNext
{
  MUHistoryRing *ring = [[MUHistoryRing alloc] init];
  
  [ring saveString:@"Foo"];
  
  [self assert:[ring nextString] equals:@"Foo"];
  [self assert:[ring nextString] equals:@""];
}

- (void) testBothWays
{
  MUHistoryRing *ring = [[MUHistoryRing alloc] init];
  
  [ring saveString:@"Foo"];
  [ring saveString:@"Bar"];
  [ring saveString:@"Baz"];
  
  [self assert:[ring previousString] equals:@"Baz"];
  [self assert:[ring previousString] equals:@"Bar"];
  [self assert:[ring nextString] equals:@"Baz"];
  [self assert:[ring nextString] equals:@""];
  [self assert:[ring nextString] equals:@"Foo"];
  [self assert:[ring nextString] equals:@"Bar"];
  [self assert:[ring previousString] equals:@"Foo"];
  [self assert:[ring previousString] equals:@""];
}

- (void) testUpdateMiddle
{
  MUHistoryRing *ring = [[MUHistoryRing alloc] init];
  
  [ring saveString:@"Foo"];
  [ring saveString:@"Bar"];
  [ring saveString:@"Baz"];

  [self assert:[ring previousString] equals:@"Baz"];
  [self assert:[ring previousString] equals:@"Bar"];
  
  [ring updateString:@"Bar Two"];
  
  [self assert:[ring previousString] equals:@"Foo"];
  [self assert:[ring previousString] equals:@""];
  [self assert:[ring previousString] equals:@"Baz"];
  [self assert:[ring previousString] equals:@"Bar Two"];
}

- (void) testUpdateBuffer
{
  MUHistoryRing *ring = [[MUHistoryRing alloc] init];
  
  [ring saveString:@"Foo"];
  [ring saveString:@"Bar"];
  
  [self assert:[ring nextString] equals:@"Foo"];
  [self assert:[ring nextString] equals:@"Bar"];
  [self assert:[ring nextString] equals:@""];
  
  [ring updateString:@"Temporary"];
  
  [self assert:[ring nextString] equals:@"Foo"];
  [self assert:[ring nextString] equals:@"Bar"];
  [self assert:[ring nextString] equals:@"Temporary"];
  
  [ring saveString:@"Something entirely different"];
  
  [self assert:[ring previousString] equals:@"Something entirely different"];
  [self assert:[ring previousString] equals:@"Bar"];
  [self assert:[ring previousString] equals:@"Foo"];
  [self assert:[ring previousString] equals:@""];
}

@end
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

NSString *First = @"First";
NSString *Second = @"Second";
NSString *Third = @"Third";

@interface MUHistoryRingTests (Private)
- (void) assertPrevious:(NSString *)expected;
- (void) assertNext:(NSString *)expected;
- (void) saveOne;
- (void) saveTwo;
- (void) saveThree;
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

- (void) saveOne
{
  [_ring saveString:First];
}

- (void) saveTwo
{
  [self saveOne];
  [_ring saveString:Second];
}

- (void) saveThree
{
  [self saveTwo];
  [_ring saveString:Third];
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
  [self saveOne];
  
  [self assertPrevious:First];
}

- (void) testMultiplePrevious
{
  [self saveThree];
  
  [self assertPrevious:Third];
  [self assertPrevious:Second];
  [self assertPrevious:First];
}

- (void) testFullCirclePrevious
{
  [self saveOne];
  
  [self assertPrevious:First];
  [self assertPrevious:@""];
}

- (void) testSingleNext
{
  [self saveOne];
  
  [self assertNext:First];
}

- (void) testMultipleNext
{
  [self saveThree];
  
  [self assertNext:First];
  [self assertNext:Second];
  [self assertNext:Third];
}

- (void) testFullCircleNext
{
  [self saveOne];
  
  [self assertNext:First];
  [self assertNext:@""];
}

- (void) testBothWays
{
  [self saveThree];
  
  [self assertPrevious:Third];
  [self assertPrevious:Second];
  [self assertNext:Third];
  [self assertNext:@""];
  [self assertNext:First];
  [self assertNext:Second];
  [self assertPrevious:First];
  [self assertPrevious:@""];
}

- (void) testUpdateMiddle
{
  [self saveThree];
  
  [self assertPrevious:Third];
  [self assertPrevious:Second];
  
  [_ring updateString:@"Bar Two"];
  
  [self assertPrevious:First];
  [self assertPrevious:@""];
  [self assertPrevious:Third];
  [self assertPrevious:@"Bar Two"];
}

- (void) testSaveReordering
{
  [self saveThree];
  
  [self assertNext:First];
  [self assertNext:Second];
  
  [_ring saveString:@"Bar Two"];
  
  [self assertNext:First];
  [self assertNext:Third];
  [self assertNext:@"Bar Two"];
  [self assertNext:@""];
}

- (void) testUpdateBuffer
{
  [self saveTwo];
  
  [self assertNext:First];
  [self assertNext:Second];
  [self assertNext:@""];
  
  [_ring updateString:@"Temporary"];
  
  [self assertNext:First];
  [self assertNext:Second];
  [self assertNext:@"Temporary"];
  
  [_ring saveString:@"Something entirely different"];
  
  [self assertPrevious:@"Something entirely different"];
  [self assertPrevious:Second];
  [self assertPrevious:First];
  [self assertPrevious:@""];
}

@end
//
// MUHistoryRingTests.m
//
// Copyright (C) 2004 3James Software
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
  [self assert:[ring previousString] equals:expected];
}

- (void) assertNext:(NSString *)expected
{
  [self assert:[ring nextString] equals:expected];
}

- (void) saveOne
{
  [ring saveString:First];
}

- (void) saveTwo
{
  [self saveOne];
  [ring saveString:Second];
}

- (void) saveThree
{
  [self saveTwo];
  [ring saveString:Third];
}

@end

@implementation MUHistoryRingTests

- (void) setUp
{
  ring = [[MUHistoryRing alloc] init];
}

- (void) tearDown
{
  [ring release];
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

- (void) testSimpleUpdate
{
  [self saveThree];
  
  [self assertPrevious:Third];
  [self assertPrevious:Second];
  
  [ring updateString:@"Bar Two"];
  
  [self assertPrevious:First];
  [self assertPrevious:@""];
  [self assertPrevious:Third];
  [self assertPrevious:@"Bar Two"];
}

- (void) testUpdateBuffer
{
  [self saveTwo];
  
  [self assertNext:First];
  [self assertNext:Second];
  [self assertNext:@""];
  
  [ring updateString:@"Temporary"];
  
  [self assertNext:First];
  [self assertNext:Second];
  [self assertNext:@"Temporary"];
  
  [ring saveString:@"Something entirely different"];
  
  [self assertPrevious:@"Something entirely different"];
  [self assertPrevious:Second];
  [self assertPrevious:First];
  [self assertPrevious:@""];
}

- (void) testInternalSave
{
  [self saveThree];
  
  [self assertNext:First];
  [self assertNext:Second];
  
  [ring saveString:@"Bar Two"];
  
  [self assertNext:First];
  [self assertNext:Second];
  [self assertNext:Third];
  [self assertNext:@"Bar Two"];
  [self assertNext:@""];
}

- (void) testUpdateThenSaveBuffer
{
  [self saveThree];
  
  [self assertPrevious:Third];
  [self assertPrevious:Second];
  
  [ring updateString:@"Bar Two"];
  
  [self assertPrevious:First];
  [self assertPrevious:@""];
  [self assertPrevious:Third];
  [self assertPrevious:@"Bar Two"];
  [self assertPrevious:First];
  [self assertPrevious:@""];
  
  [ring saveString:@"New"];
  
  [self assertPrevious:@"New"];
  [self assertPrevious:Third];
  [self assertPrevious:@"Bar Two"];
}

- (void) testUpdateAndSaveUpdatedValue
{
  [self saveThree];
  
  [self assertPrevious:Third];
  [self assertPrevious:Second];
  
  [ring updateString:@"Bar Two"];
  
  [self assertPrevious:First];
  [self assertPrevious:@""];
  [self assertPrevious:Third];
  [self assertPrevious:@"Bar Two"];
  
  [ring saveString:@"Updated Bar"];
  
  [self assertPrevious:@"Updated Bar"];
  [self assertPrevious:Third];
  [self assertPrevious:Second];
}

- (void) testNonduplicationOfPreviousCommand
{
  [self saveOne];
  
  [self assertPrevious:First];
  
  [ring saveString:First];
  
  [self assertPrevious:First];
  [self assertPrevious:@""];
}

@end

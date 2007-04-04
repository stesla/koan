//
// J3HistoryRingTests.m
//
// Copyright (c) 2007 3James Software.
//

#import "J3HistoryRingTests.h"

NSString *First = @"First";
NSString *Second = @"Second";
NSString *Third = @"Third";

@interface J3HistoryRingTests (Private)

- (void) assertCurrent: (NSString *) expected;
- (void) assertPrevious: (NSString *) expected;
- (void) assertNext: (NSString *) expected;
- (void) saveOne;
- (void) saveTwo;
- (void) saveThree;

@end

#pragma mark -

@implementation J3HistoryRingTests (Private)

- (void) assertCurrent: (NSString *) expected
{
  [self assert: [ring currentString] equals: expected];
}

- (void) assertPrevious: (NSString *) expected
{
  [self assert: [ring previousString] equals: expected];
}

- (void) assertNext: (NSString *) expected
{
  [self assert: [ring nextString] equals: expected];
}

- (void) saveOne
{
  [ring saveString: First];
}

- (void) saveTwo
{
  [self saveOne];
  [ring saveString: Second];
}

- (void) saveThree
{
  [self saveTwo];
  [ring saveString: Third];
}

@end

#pragma mark -

@implementation J3HistoryRingTests

- (void) setUp
{
  ring = [[J3HistoryRing alloc] init];
}

- (void) tearDown
{
  [ring release];
}

- (void) testSinglePrevious
{
  [self saveOne];
  
  [self assertPrevious: First];
}

- (void) testMultiplePrevious
{
  [self saveThree];
  
  [self assertPrevious: Third];
  [self assertPrevious: Second];
  [self assertPrevious: First];
}

- (void) testFullCirclePrevious
{
  [self saveOne];
  
  [self assertPrevious: First];
  [self assertPrevious: @""];
}

- (void) testSingleNext
{
  [self saveOne];
  
  [self assertNext: First];
}

- (void) testMultipleNext
{
  [self saveThree];
  
  [self assertNext: First];
  [self assertNext: Second];
  [self assertNext: Third];
}

- (void) testFullCircleNext
{
  [self saveOne];
  
  [self assertNext: First];
  [self assertNext: @""];
}

- (void) testBothWays
{
  [self saveThree];
  
  [self assertPrevious: Third];
  [self assertPrevious: Second];
  [self assertNext: Third];
  [self assertNext: @""];
  [self assertNext: First];
  [self assertNext: Second];
  [self assertPrevious: First];
  [self assertPrevious: @""];
}

- (void) testCurrentString
{
  [self saveThree];
  
  [self assertNext: First];
  [self assertCurrent: First];
  [self assertNext: Second];
  [self assertCurrent: Second];
  [self assertNext: Third];
  [self assertCurrent: Third];
  [self assertNext: @""];
  [self assertCurrent: @""];
}

- (void) testSimpleUpdate
{
  [self saveThree];
  
  [self assertPrevious: Third];
  [self assertPrevious: Second];
  
  [ring updateString: @"Bar Two"];
  
  [self assertPrevious: First];
  [self assertPrevious: @""];
  [self assertPrevious: Third];
  [self assertPrevious: @"Bar Two"];
}

- (void) testUpdateBuffer
{
  [self saveTwo];
  
  [self assertNext: First];
  [self assertNext: Second];
  [self assertNext: @""];
  
  [ring updateString: @"Temporary"];
  
  [self assertNext: First];
  [self assertNext: Second];
  [self assertNext: @"Temporary"];
  
  [ring saveString: @"Something entirely different"];
  
  [self assertPrevious: @"Something entirely different"];
  [self assertPrevious: Second];
  [self assertPrevious: First];
  [self assertPrevious: @""];
}

- (void) testInternalSave
{
  [self saveThree];
  
  [self assertNext: First];
  [self assertNext: Second];
  
  [ring saveString: @"Bar Two"];
  
  [self assertNext: First];
  [self assertNext: Second];
  [self assertNext: Third];
  [self assertNext: @"Bar Two"];
  [self assertNext: @""];
}

- (void) testUpdateThenSaveBuffer
{
  [self saveThree];
  
  [self assertPrevious: Third];
  [self assertPrevious: Second];
  
  [ring updateString: @"Bar Two"];
  
  [self assertPrevious: First];
  [self assertPrevious: @""];
  [self assertPrevious: Third];
  [self assertPrevious: @"Bar Two"];
  [self assertPrevious: First];
  [self assertPrevious: @""];
  
  [ring saveString: @"New"];
  
  [self assertPrevious: @"New"];
  [self assertPrevious: Third];
  [self assertPrevious: @"Bar Two"];
}

- (void) testUpdateAndSaveUpdatedValue
{
  [self saveThree];
  
  [self assertPrevious: Third];
  [self assertPrevious: Second];
  
  [ring updateString: @"Bar Two"];
  
  [self assertPrevious: First];
  [self assertPrevious: @""];
  [self assertPrevious: Third];
  [self assertPrevious: @"Bar Two"];
  
  [ring saveString: @"Updated Bar"];
  
  [self assertPrevious: @"Updated Bar"];
  [self assertPrevious: Third];
  [self assertPrevious: Second];
}

- (void) testNonduplicationOfPreviousCommand
{
  [self saveOne];
  
  [self assertPrevious: First];
  
  [ring saveString: First];
  
  [self assertPrevious: First];
  [self assertPrevious: @""];
}

- (void) testSearchFindsNothing
{
  [ring saveString: @"Dog"];
  
  [self assertNil: [ring searchForwardForStringPrefix: @"Cat"]];
}

- (void) testPerfectMatchFindsNothing
{
  [ring saveString: @"Cat"];
  
  [self assertNil: [ring searchForwardForStringPrefix: @"Cat"]];
}

- (void) testSearchForward
{
  [ring saveString: @"Catastrophic"];
  [ring saveString: @"Dog"];
  [ring saveString: @"Catatonic"];
  
  [self assert: [ring searchForwardForStringPrefix: @"Cat"] equals: @"Catastrophic"];
  [self assert: [ring searchForwardForStringPrefix: @"Cat"] equals: @"Catatonic"];
}

- (void) testWraparoundSearchForward
{
  [ring saveString: @"Catastrophic"];
  [ring saveString: @"Dog"];
  [ring saveString: @"Catatonic"];
  
  [self assert: [ring searchForwardForStringPrefix: @"Cat"] equals: @"Catastrophic"];
  [self assert: [ring searchForwardForStringPrefix: @"Cat"] equals: @"Catatonic"];
  [self assert: [ring searchForwardForStringPrefix: @"Cat"] equals: @"Catastrophic"];
  [self assert: [ring searchForwardForStringPrefix: @"Cat"] equals: @"Catatonic"];
}

- (void) testMoveForwardThenSearchForward
{
  [ring saveString: @"Catastrophic"];
  [ring saveString: @"Dog"];
  [ring saveString: @"Catatonic"];
  
  [self assertNext: @"Catastrophic"];
  
  [self assert: [ring searchForwardForStringPrefix: @"Cat"] equals: @"Catatonic"];
  [self assert: [ring searchForwardForStringPrefix: @"Cat"] equals: @"Catastrophic"];
}

- (void) testMoveBackwardThenSearchForward
{
  [ring saveString: @"Catastrophic"];
  [ring saveString: @"Dog"];
  [ring saveString: @"Catatonic"];
  
  [self assertPrevious: @"Catatonic"];
  
  [self assert: [ring searchForwardForStringPrefix: @"Cat"] equals: @"Catastrophic"];
  [self assert: [ring searchForwardForStringPrefix: @"Cat"] equals: @"Catatonic"];
  
  [self assertPrevious: @"Dog"];
  
  [self assert: [ring searchForwardForStringPrefix: @"Cat"] equals: @"Catatonic"];
  [self assert: [ring searchForwardForStringPrefix: @"Cat"] equals: @"Catastrophic"];
}

- (void) testSearchForwardWithInterspersedResets
{
  [ring saveString: @"Catastrophic"];
  [ring saveString: @"Catalogue"];
  [ring saveString: @"Catatonic"];
  
  [self assert: [ring searchForwardForStringPrefix: @"Cat"] equals: @"Catastrophic"];
  [ring resetSearchCursor];
  [self assert: [ring searchForwardForStringPrefix: @"Cat"] equals: @"Catastrophic"];
  [self assert: [ring searchForwardForStringPrefix: @"Cat"] equals: @"Catalogue"];
  [ring resetSearchCursor];
  [self assert: [ring searchForwardForStringPrefix: @"Cat"] equals: @"Catastrophic"];
  [self assert: [ring searchForwardForStringPrefix: @"Cat"] equals: @"Catalogue"];
  [self assert: [ring searchForwardForStringPrefix: @"Cat"] equals: @"Catatonic"];
}

- (void) testSearchBackward
{
  [ring saveString: @"Catastrophic"];
  [ring saveString: @"Dog"];
  [ring saveString: @"Catatonic"];
  
  [self assert: [ring searchBackwardForStringPrefix: @"Cat"] equals: @"Catatonic"];
  [self assert: [ring searchBackwardForStringPrefix: @"Cat"] equals: @"Catastrophic"];
}

- (void) testMoveForwardThenSearchBackward
{
  [ring saveString: @"Catastrophic"];
  [ring saveString: @"Dog"];
  [ring saveString: @"Catatonic"];
  
  [self assertNext: @"Catastrophic"];
  
  [self assert: [ring searchBackwardForStringPrefix: @"Cat"] equals: @"Catatonic"];
  [self assert: [ring searchBackwardForStringPrefix: @"Cat"] equals: @"Catastrophic"];
  
  [self assertNext: @"Dog"];
  
  [self assert: [ring searchBackwardForStringPrefix: @"Cat"] equals: @"Catastrophic"];
  [self assert: [ring searchBackwardForStringPrefix: @"Cat"] equals: @"Catatonic"];
  
}

- (void) testMoveBackwardThenSearchBackward
{
  [ring saveString: @"Catastrophic"];
  [ring saveString: @"Dog"];
  [ring saveString: @"Catatonic"];
  
  [self assertPrevious: @"Catatonic"];
  
  [self assert: [ring searchBackwardForStringPrefix: @"Cat"] equals: @"Catastrophic"];
  [self assert: [ring searchBackwardForStringPrefix: @"Cat"] equals: @"Catatonic"];
}

- (void) testSearchBackwardWithInterspersedResets
{
  [ring saveString: @"Catastrophic"];
  [ring saveString: @"Catalogue"];
  [ring saveString: @"Catatonic"];
  
  [self assert: [ring searchBackwardForStringPrefix: @"Cat"] equals: @"Catatonic"];
  [ring resetSearchCursor];
  [self assert: [ring searchBackwardForStringPrefix: @"Cat"] equals: @"Catatonic"];
  [self assert: [ring searchBackwardForStringPrefix: @"Cat"] equals: @"Catalogue"];
  [ring resetSearchCursor];
  [self assert: [ring searchBackwardForStringPrefix: @"Cat"] equals: @"Catatonic"];
  [self assert: [ring searchBackwardForStringPrefix: @"Cat"] equals: @"Catalogue"];
  [self assert: [ring searchBackwardForStringPrefix: @"Cat"] equals: @"Catastrophic"];
}

- (void) testSearchForwardAndBackward
{
  [ring saveString: @"Catastrophic"];
  [ring saveString: @"Catalogue"];
  [ring saveString: @"Catatonic"];
  
  [self assert: [ring searchForwardForStringPrefix: @"Cat"] equals: @"Catastrophic"];
  [self assert: [ring searchForwardForStringPrefix: @"Cat"] equals: @"Catalogue"];
  [self assert: [ring searchForwardForStringPrefix: @"Cat"] equals: @"Catatonic"];
  [self assert: [ring searchBackwardForStringPrefix: @"Cat"] equals: @"Catalogue"];
  [self assert: [ring searchBackwardForStringPrefix: @"Cat"] equals: @"Catastrophic"];
  [self assert: [ring searchForwardForStringPrefix: @"Cat"] equals: @"Catalogue"];
  [self assert: [ring searchForwardForStringPrefix: @"Cat"] equals: @"Catatonic"];
}

- (void) testSearchHonorsUpdates
{
  [ring saveString: @"Catastrophic"];
  [ring saveString: @"Dog"];
  [ring saveString: @"Catatonic"];
  
  [self assert: [ring searchForwardForStringPrefix: @"Cat"] equals: @"Catastrophic"];
  [self assert: [ring searchForwardForStringPrefix: @"Cat"] equals: @"Catatonic"];
  
  [self assertNext: @"Catastrophic"];
  [self assertNext: @"Dog"];
  
  [ring updateString: @"Catalogue"];
  
  [self assert: [ring searchForwardForStringPrefix: @"Cat"] equals: @"Catatonic"];
  [self assert: [ring searchForwardForStringPrefix: @"Cat"] equals: @"Catastrophic"];
  [self assert: [ring searchForwardForStringPrefix: @"Cat"] equals: @"Catalogue"];
}

- (void) testSearchForEmptyString
{
  [ring saveString: @"Pixel"];
  
  [self assertNil: [ring searchForwardForStringPrefix: @""]];
  [self assertNil: [ring searchBackwardForStringPrefix: @""]];
}

- (void) testNumberOfUniqueMatches
{
  [ring saveString: @"Dog"];
  
  [self assertInt: [ring numberOfUniqueMatchesForStringPrefix: @"Cat"]
           equals: 0];
  
  [ring saveString: @"Cat"];
  
  [self assertInt: [ring numberOfUniqueMatchesForStringPrefix: @"Cat"]
           equals: 0];
  
  [ring saveString: @"Catatonic"];
  
  [self assertInt: [ring numberOfUniqueMatchesForStringPrefix: @"Cat"]
           equals: 1];
  
  [ring saveString: @"Catastrophic"];
  
  [self assertInt: [ring numberOfUniqueMatchesForStringPrefix: @"Cat"]
           equals: 2];
  
  [ring saveString: @"Catastrophic"];
  
  [self assertInt: [ring numberOfUniqueMatchesForStringPrefix: @"Cat"]
           equals: 2];
}

@end

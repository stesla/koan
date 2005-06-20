//
// MUProfileTests.m
//
// Copyright (c) 2005 3James Software
//

#import "MUUpdateIntervalTests.h"
#import "MUUpdateInterval.h"

@implementation MUUpdateIntervalTests

- (void) testNilInput
{
  MUUpdateInterval *interval = [MUUpdateInterval intervalWithType:MUOnLaunchUpdateType];
  
  [self assertFalse:[interval shouldUpdateForBaseDate:nil]];
  [self assertFalse:[interval shouldUpdateForBaseDate:nil candidateDate:nil]];
  [self assertFalse:[interval shouldUpdateForBaseDate:[NSDate dateWithNaturalLanguageString:@"1:00 p.m. January 1, 2001"]
                                        candidateDate:nil]];
  [self assertFalse:[interval shouldUpdateForBaseDate:nil
                                        candidateDate:[NSDate dateWithNaturalLanguageString:@"1:00 p.m. January 1, 2001"]]];
}

- (void) testOnLaunchInterval
{
  MUUpdateInterval *interval = [MUUpdateInterval intervalWithType:MUOnLaunchUpdateType];
  
  [self assertFalse:
    [interval shouldUpdateForBaseDate:[NSDate dateWithNaturalLanguageString:@"1:00 p.m. January 1, 2001"]
                        candidateDate:[NSDate dateWithNaturalLanguageString:@"5:00 p.m. January 1, 2001"]]
            message:@"On Launch updated for a 4 hour difference."];
  [self assertFalse:
    [interval shouldUpdateForBaseDate:[NSDate dateWithNaturalLanguageString:@"1:00 p.m. January 1, 2001"]
                        candidateDate:[NSDate dateWithNaturalLanguageString:@"2:00 p.m. January 2, 2001"]]
            message:@"On Launch updated for a 1 day difference."];
  [self assertFalse:
    [interval shouldUpdateForBaseDate:[NSDate dateWithNaturalLanguageString:@"1:00 p.m. January 1, 2001"]
                        candidateDate:[NSDate dateWithNaturalLanguageString:@"2:00 p.m. January 8, 2001"]]
            message:@"On Launch updated for a 1 week difference."];
  [self assertFalse:
    [interval shouldUpdateForBaseDate:[NSDate dateWithNaturalLanguageString:@"1:00 p.m. January 1, 2001"]
                        candidateDate:[NSDate dateWithNaturalLanguageString:@"2:00 p.m. February 1, 2001"]]
            message:@"On Launch updated for a 1 month difference."];
}

- (void) testDailyInterval
{
  MUUpdateInterval *interval = [MUUpdateInterval intervalWithType:MUDailyUpdateType];
  
  [self assertFalse:
    [interval shouldUpdateForBaseDate:[NSDate dateWithNaturalLanguageString:@"1:00 p.m. January 1, 2001"]
                        candidateDate:[NSDate dateWithNaturalLanguageString:@"5:00 p.m. January 1, 2001"]]
            message:@"Daily updated for a 4 hour difference."];
  [self assertTrue:
    [interval shouldUpdateForBaseDate:[NSDate dateWithNaturalLanguageString:@"1:00 p.m. January 1, 2001"]
                        candidateDate:[NSDate dateWithNaturalLanguageString:@"2:00 p.m. January 2, 2001"]]
           message:@"Daily did not update for a 1 day difference."];
  [self assertTrue:
    [interval shouldUpdateForBaseDate:[NSDate dateWithNaturalLanguageString:@"1:00 p.m. January 1, 2001"]
                        candidateDate:[NSDate dateWithNaturalLanguageString:@"2:00 p.m. January 8, 2001"]]
           message:@"Daily did not update for a 1 week difference."];
  [self assertTrue:
    [interval shouldUpdateForBaseDate:[NSDate dateWithNaturalLanguageString:@"1:00 p.m. January 1, 2001"]
                        candidateDate:[NSDate dateWithNaturalLanguageString:@"2:00 p.m. February 1, 2001"]]
           message:@"Daily did not update for a 1 month difference."];
}

- (void) testWeeklyInterval
{
  MUUpdateInterval *interval = [MUUpdateInterval intervalWithType:MUWeeklyUpdateType];
  
  [self assertFalse:
    [interval shouldUpdateForBaseDate:[NSDate dateWithNaturalLanguageString:@"1:00 p.m. January 1, 2001"]
                        candidateDate:[NSDate dateWithNaturalLanguageString:@"5:00 p.m. January 1, 2001"]]
            message:@"Weekly updated for a 4 hour difference."];
  [self assertFalse:
    [interval shouldUpdateForBaseDate:[NSDate dateWithNaturalLanguageString:@"1:00 p.m. January 1, 2001"]
                        candidateDate:[NSDate dateWithNaturalLanguageString:@"2:00 p.m. January 2, 2001"]]
           message:@"Weekly updated for a 1 day difference."];
  [self assertTrue:
    [interval shouldUpdateForBaseDate:[NSDate dateWithNaturalLanguageString:@"1:00 p.m. January 1, 2001"]
                        candidateDate:[NSDate dateWithNaturalLanguageString:@"2:00 p.m. January 8, 2001"]]
           message:@"Weekly did not update for a 1 week difference."];
  [self assertTrue:
    [interval shouldUpdateForBaseDate:[NSDate dateWithNaturalLanguageString:@"1:00 p.m. January 1, 2001"]
                        candidateDate:[NSDate dateWithNaturalLanguageString:@"2:00 p.m. February 1, 2001"]]
           message:@"Weekly did not update for a 1 month difference."];
}

- (void) testMonthlyInterval
{
  MUUpdateInterval *interval = [MUUpdateInterval intervalWithType:MUMonthlyUpdateType];
  
  [self assertFalse:
    [interval shouldUpdateForBaseDate:[NSDate dateWithNaturalLanguageString:@"1:00 p.m. January 1, 2001"]
                        candidateDate:[NSDate dateWithNaturalLanguageString:@"5:00 p.m. January 1, 2001"]]
            message:@"Monthly updated for a 4 hour difference."];
  [self assertFalse:
    [interval shouldUpdateForBaseDate:[NSDate dateWithNaturalLanguageString:@"1:00 p.m. January 1, 2001"]
                        candidateDate:[NSDate dateWithNaturalLanguageString:@"2:00 p.m. January 2, 2001"]]
            message:@"Monthly updated for a 1 day difference."];
  [self assertFalse:
    [interval shouldUpdateForBaseDate:[NSDate dateWithNaturalLanguageString:@"1:00 p.m. January 1, 2001"]
                        candidateDate:[NSDate dateWithNaturalLanguageString:@"2:00 p.m. January 8, 2001"]]
            message:@"Monthly updated for a 1 week difference."];
  [self assertFalse:
    [interval shouldUpdateForBaseDate:[NSDate dateWithNaturalLanguageString:@"1:00 p.m. January 1, 2001"]
                        candidateDate:[NSDate dateWithNaturalLanguageString:@"2:00 p.m. January 29, 2001"]]
            message:@"Monthly updated for a 28 day difference."];
  [self assertTrue:
    [interval shouldUpdateForBaseDate:[NSDate dateWithNaturalLanguageString:@"1:00 p.m. January 1, 2001"]
                        candidateDate:[NSDate dateWithNaturalLanguageString:@"2:00 p.m. February 1, 2001"]]
           message:@"Monthly did not update for a 1 month difference (Jan-Feb)."];
  [self assertTrue:
    [interval shouldUpdateForBaseDate:[NSDate dateWithNaturalLanguageString:@"1:00 p.m. February 1, 2001"]
                        candidateDate:[NSDate dateWithNaturalLanguageString:@"2:00 p.m. March 1, 2001"]]
           message:@"Monthly did not update for a 1 month difference (Feb-Mar)."];
}

@end

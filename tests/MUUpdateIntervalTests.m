//
// MUProfileTests.m
//
// Copyright (c) 2005 3James Software
//

#import "MUUpdateIntervalTests.h"
#import "MUUpdateInterval.h"

@implementation MUUpdateIntervalTests

- (void) testOnLaunchInterval
{
  MUUpdateInterval *interval = [MUUpdateInterval intervalWithType:MUOnLaunchUpdateType];
  
  [self assertFalse:
    [interval shouldUpdateForBaseDate:[NSDate dateWithNaturalLanguageString:@"1:00 p.m. January 1, 2001"]
                        candidateDate:[NSDate dateWithNaturalLanguageString:@"5:00 p.m. January 1, 2001"]]];
  [self assertFalse:
    [interval shouldUpdateForBaseDate:[NSDate dateWithNaturalLanguageString:@"1:00 p.m. January 1, 2001"]
                        candidateDate:[NSDate dateWithNaturalLanguageString:@"2:00 p.m. January 2, 2001"]]];
  [self assertFalse:
    [interval shouldUpdateForBaseDate:[NSDate dateWithNaturalLanguageString:@"1:00 p.m. January 1, 2001"]
                        candidateDate:[NSDate dateWithNaturalLanguageString:@"2:00 p.m. January 8, 2001"]]];
  [self assertFalse:
    [interval shouldUpdateForBaseDate:[NSDate dateWithNaturalLanguageString:@"1:00 p.m. January 1, 2001"]
                        candidateDate:[NSDate dateWithNaturalLanguageString:@"2:00 p.m. February 1, 2001"]]];
}

- (void) testDailyInterval
{
  MUUpdateInterval *interval = [MUUpdateInterval intervalWithType:MUDailyUpdateType];
  
  [self assertFalse:
    [interval shouldUpdateForBaseDate:[NSDate dateWithNaturalLanguageString:@"1:00 p.m. January 1, 2001"]
                        candidateDate:[NSDate dateWithNaturalLanguageString:@"5:00 p.m. January 1, 2001"]]];
  [self assertTrue:
    [interval shouldUpdateForBaseDate:[NSDate dateWithNaturalLanguageString:@"1:00 p.m. January 1, 2001"]
                        candidateDate:[NSDate dateWithNaturalLanguageString:@"2:00 p.m. January 2, 2001"]]];
  [self assertTrue:
    [interval shouldUpdateForBaseDate:[NSDate dateWithNaturalLanguageString:@"1:00 p.m. January 1, 2001"]
                        candidateDate:[NSDate dateWithNaturalLanguageString:@"2:00 p.m. January 8, 2001"]]];
  [self assertTrue:
    [interval shouldUpdateForBaseDate:[NSDate dateWithNaturalLanguageString:@"1:00 p.m. January 1, 2001"]
                        candidateDate:[NSDate dateWithNaturalLanguageString:@"2:00 p.m. February 1, 2001"]]];
}

- (void) testWeeklyInterval
{
  MUUpdateInterval *interval = [MUUpdateInterval intervalWithType:MUWeeklyUpdateType];
  
  [self assertFalse:
    [interval shouldUpdateForBaseDate:[NSDate dateWithNaturalLanguageString:@"1:00 p.m. January 1, 2001"]
                        candidateDate:[NSDate dateWithNaturalLanguageString:@"5:00 p.m. January 1, 2001"]]];
  [self assertFalse:
    [interval shouldUpdateForBaseDate:[NSDate dateWithNaturalLanguageString:@"1:00 p.m. January 1, 2001"]
                        candidateDate:[NSDate dateWithNaturalLanguageString:@"2:00 p.m. January 2, 2001"]]];
  [self assertTrue:
    [interval shouldUpdateForBaseDate:[NSDate dateWithNaturalLanguageString:@"1:00 p.m. January 1, 2001"]
                        candidateDate:[NSDate dateWithNaturalLanguageString:@"2:00 p.m. January 8, 2001"]]];
  [self assertTrue:
    [interval shouldUpdateForBaseDate:[NSDate dateWithNaturalLanguageString:@"1:00 p.m. January 1, 2001"]
                        candidateDate:[NSDate dateWithNaturalLanguageString:@"2:00 p.m. February 1, 2001"]]];
}

@end

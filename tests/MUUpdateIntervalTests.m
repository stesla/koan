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
    [interval shouldUpdateForCandidateDate:[NSDate dateWithNaturalLanguageString:@"1:00 p.m. January 1, 2001"]
                                  baseDate:[NSDate dateWithNaturalLanguageString:@"5:00 p.m. January 1, 2001"]]];
}

@end

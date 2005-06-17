//
// MUUpdateInterval.h
//
// Copyright (c) 2005 3James Software
//

#import <Cocoa/Cocoa.h>

enum MUUpdateIntervalTypes
{
  MUOnLaunchUpdateType,
  MUDailyUpdateType,
  MUWeeklyUpdateType,
  MUMonthlyUpdateType
};

@interface MUUpdateInterval : NSObject
{
}

+ (MUUpdateInterval *) intervalWithType:(enum MUUpdateIntervalTypes)newType;

// Designated initializer.
- (id) initWithType:(enum MUUpdateIntervalTypes)newType;

- (BOOL) shouldUpdateForCandidateDate:(NSDate *)candidateDate baseDate:(NSDate *)baseDate;
- (BOOL) shouldUpdateForBaseDate:(NSDate *)baseDate;

@end

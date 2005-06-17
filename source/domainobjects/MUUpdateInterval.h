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
  enum MUUpdateIntervalTypes type;
}

+ (MUUpdateInterval *) intervalWithType:(enum MUUpdateIntervalTypes)newType;

// Designated initializer.
- (id) initWithType:(enum MUUpdateIntervalTypes)newType;

- (BOOL) shouldUpdateForBaseDate:(NSDate *)baseDate candidateDate:(NSDate *)candidateDate;
- (BOOL) shouldUpdateForBaseDate:(NSDate *)baseDate;

@end

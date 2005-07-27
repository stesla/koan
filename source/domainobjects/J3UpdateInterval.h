//
// J3UpdateInterval.h
//
// Copyright (c) 2005 3James Software
//

#import <Cocoa/Cocoa.h>

enum J3UpdateIntervalTypes
{
  J3OnLaunchUpdateType,
  J3DailyUpdateType,
  J3WeeklyUpdateType,
  J3MonthlyUpdateType
};

@interface J3UpdateInterval : NSObject
{
  enum J3UpdateIntervalTypes type;
}

+ (J3UpdateInterval *) intervalWithType:(enum J3UpdateIntervalTypes)newType;

// Designated initializer.
- (id) initWithType:(enum J3UpdateIntervalTypes)newType;

- (BOOL) shouldUpdateForBaseDate:(NSDate *)baseDate candidateDate:(NSDate *)candidateDate;
- (BOOL) shouldUpdateForBaseDate:(NSDate *)baseDate;

@end

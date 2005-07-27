//
// J3UpdateInterval.m
//
// Copyright (c) 2005 3James Software
//

#import "J3UpdateInterval.h"

@implementation J3UpdateInterval

+ (J3UpdateInterval *) intervalWithType:(enum J3UpdateIntervalTypes)newType
{
  return [[[J3UpdateInterval alloc] initWithType:newType] autorelease];
}

- (id) initWithType:(enum J3UpdateIntervalTypes)newType
{
  if (self = [super init])
  {
    type = newType;
  }
  return self;
}

#pragma mark -
#pragma mark Actions

- (BOOL) shouldUpdateForBaseDate:(NSDate *)baseDate candidateDate:(NSDate *)candidateDate
{
  if (type == J3OnLaunchUpdateType)
    return NO;
  else
  {
    NSCalendarDate *baseCalendarDate = [NSCalendarDate dateWithTimeIntervalSinceReferenceDate:[baseDate timeIntervalSinceReferenceDate]];
    int months = 0;
    int days = 0;
    NSCalendarDate *adjustedDate;

    if (type == J3MonthlyUpdateType)
      months = 1;
    if (type == J3WeeklyUpdateType)
      days = 7;
    if (type == J3DailyUpdateType)
      days = 1;
    
    adjustedDate = [baseCalendarDate dateByAddingYears:0
                                                months:months
                                                  days:days
                                                 hours:0
                                               minutes:0
                                               seconds:0];
    
    return ([adjustedDate compare:candidateDate] == NSOrderedDescending ? NO : YES);
  }
}

- (BOOL) shouldUpdateForBaseDate:(NSDate *)baseDate
{
  return [self shouldUpdateForBaseDate:baseDate candidateDate:[NSDate date]];
}

@end

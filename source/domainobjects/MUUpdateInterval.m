//
// MUUpdateInterval.m
//
// Copyright (c) 2005 3James Software
//

#import "MUUpdateInterval.h"

@implementation MUUpdateInterval

+ (MUUpdateInterval *) intervalWithType:(enum MUUpdateIntervalTypes)newType
{
  return [[[MUUpdateInterval alloc] initWithType:newType] autorelease];
}

- (id) initWithType:(enum MUUpdateIntervalTypes)newType
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
  if (type == MUOnLaunchUpdateType)
    return NO;
  else
  {
    NSCalendarDate *baseCalendarDate = [NSCalendarDate dateWithTimeIntervalSinceReferenceDate:[baseDate timeIntervalSinceReferenceDate]];
    int months = 0;
    int days = 0;
    NSCalendarDate *adjustedDate;

    if (type == MUMonthlyUpdateType)
      months = 1;
    if (type == MUWeeklyUpdateType)
      days = 7;
    if (type == MUDailyUpdateType)
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

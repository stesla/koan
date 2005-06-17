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
  if (type == MUDailyUpdateType)
  {
    NSCalendarDate *baseCalendarDate = [NSCalendarDate dateWithTimeIntervalSinceReferenceDate:[baseDate timeIntervalSinceReferenceDate]];
    NSCalendarDate *adjustedDate = [baseCalendarDate dateByAddingYears:0
                                                                months:0
                                                                  days:1
                                                                 hours:0
                                                               minutes:0
                                                               seconds:0];
    
    return ([adjustedDate compare:candidateDate] == NSOrderedDescending ? NO : YES);
  }
  else if (type == MUWeeklyUpdateType)
  {
    NSCalendarDate *baseCalendarDate = [NSCalendarDate dateWithTimeIntervalSinceReferenceDate:[baseDate timeIntervalSinceReferenceDate]];
    NSCalendarDate *adjustedDate = [baseCalendarDate dateByAddingYears:0
                                                                months:0
                                                                  days:7
                                                                 hours:0
                                                               minutes:0
                                                               seconds:0];
    
    return ([adjustedDate compare:candidateDate] == NSOrderedDescending ? NO : YES);
  }
  else
    return NO;
}

- (BOOL) shouldUpdateForBaseDate:(NSDate *)baseDate
{
  return [self shouldUpdateForBaseDate:baseDate candidateDate:[NSDate date]];
}

@end

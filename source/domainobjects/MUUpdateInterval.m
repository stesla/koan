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
    
  }
  return self;
}

#pragma mark -
#pragma mark Actions

- (BOOL) shouldUpdateForCandidateDate:(NSDate *)candidateDate baseDate:(NSDate *)baseDate
{
  return NO;
}

- (BOOL) shouldUpdateForBaseDate:(NSDate *)baseDate
{
  return [self shouldUpdateForCandidateDate:[NSDate date] baseDate:baseDate];
}

@end

//
// MUFilter.m
//
// Copyright (C) 2004 3James Software
//

#import "MUFilter.h"

@implementation MUFilter

+ (MUFilter *) filter
{
  return [[[MUFilter alloc] init] autorelease];
}

- (NSAttributedString *) filter:(NSAttributedString *)string
{
  return string;
}

@end

@implementation MUFilterQueue

- (id) init
{
  if (self = [super init])
  {
    filters = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void) dealloc
{
  [filters release];
}

- (NSAttributedString *) processAttributedString:(NSAttributedString *)string
{
  NSAttributedString *returnString = string;
  
  id <MUFiltering> filter = nil;
  int i;
  for (i = 0; i < [filters count]; i++)
  {
    filter = (id <MUFiltering>) [filters objectAtIndex:i];
    returnString = [filter filter:returnString];
  }
  return returnString;
}

- (void) addFilter:(id <MUFiltering>)filter
{
  [filters addObject:filter];
}

@end

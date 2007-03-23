//
// J3Filter.m
//
// Copyright (c) 2004, 2005, 2006 3James Software
//

#import "J3Filter.h"

@implementation J3Filter

+ (J3Filter *) filter
{
  return [[[self alloc] init] autorelease];
}

- (NSAttributedString *) filter: (NSAttributedString *) string
{
  return string;
}

@end

@implementation J3FilterQueue

- (id) init
{
  if (![super init])
    return nil;
  [self clearFilters];
  return self;
}

- (void) dealloc
{
  [filters release];
  [super dealloc];
}

- (NSAttributedString *) processAttributedString: (NSAttributedString *) string
{
  NSAttributedString *returnString = string;
  
  id <J3Filtering> filter = nil;
  int i;
  for (i = 0; i < [filters count]; i++)
  {
    filter = (id <J3Filtering>) [filters objectAtIndex: i];
    returnString = [filter filter: returnString];
  }
  return returnString;
}

- (void) addFilter: (id <J3Filtering>) filter
{
  [filters addObject: filter];
}

- (void) clearFilters;
{
  [self at: &filters put: [NSMutableArray array]];
}

@end

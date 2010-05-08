//
// J3Filter.m
//
// Copyright (c) 2010 3James Software.
//

#import "J3Filter.h"

@implementation J3Filter

+ (id) filter
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
  if (!(self = [super init]))
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
  
  NSObject <J3Filtering> *filter = nil;
  
  for (unsigned i = 0; i < [filters count]; i++)
  {
    filter = (NSObject <J3Filtering> *) [filters objectAtIndex: i];
    returnString = [filter filter: returnString];
  }
  return returnString;
}

- (void) addFilter: (NSObject <J3Filtering> *) filter
{
  [filters addObject: filter];
}

- (void) clearFilters
{
  [self at: &filters put: [NSMutableArray array]];
}

@end

//
// MUHistoryRing.m
//
// Copyright (C) 2004 3James Software
//

#import "MUHistoryRing.h"

@implementation MUHistoryRing

- (id) init
{
  if (self = [super init])
  {
    ring = [[NSMutableArray alloc] init];
    updates = [[NSMutableDictionary alloc] init];
    cursor = -1;
  }
  return self;
}

- (void) dealloc
{
  [ring release];
  [updates release];
  [super dealloc];
}

- (void) saveString:(NSString *)string
{
  NSString *copy = [[string copy] autorelease];
  
  [updates removeObjectForKey:[NSNumber numberWithInt:cursor]];
  
  if (!((cursor != -1) && (cursor == [ring count] - 1) && [string isEqualToString:[ring objectAtIndex:cursor]]))
  {
    [ring addObject:copy];
  }
  [buffer release];
  buffer = nil;
  cursor = -1;
}

- (void) updateString:(NSString *)string
{
  NSString *copy = [string copy];
  
  if (cursor == -1)
  {
    [buffer release];
    buffer = copy;
  }
  else
  {
    [updates setObject:[copy autorelease] forKey:[NSNumber numberWithInt:cursor]];
  }
}

- (NSString *) nextString
{
  cursor++;
  
  if (cursor >= [ring count] || cursor < -1)
  {
    cursor = -1;
    return buffer == nil ? @"" : buffer;
  }
  else
  {
    NSString *string = [updates objectForKey:[NSNumber numberWithInt:cursor]];
    
    if (string)
      return string;
    else
      return [ring objectAtIndex:cursor];
  }
}

- (NSString *) previousString
{
  cursor--;
  
  if (cursor == -2)
    cursor = [ring count] - 1;
  else if (cursor >= [ring count] || cursor < -2)
    cursor = -1;
  
  if (cursor == -1)
    return buffer == nil ? @"" : buffer;
  else
  {
    NSString *string = [updates objectForKey:[NSNumber numberWithInt:cursor]];
    
    if (string)
      return string;
    else
      return [ring objectAtIndex:cursor];
  }
}

@end

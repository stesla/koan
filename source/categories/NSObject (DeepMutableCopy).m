//
// NSObject (DeepMutableCopy).m
//
// Copyright (c) 2004, 2005 3James Software
//
// This file is in the public domain.
//

#import "NSObject (DeepMutableCopy).h"

@implementation NSObject (DeepMutableCopy)

- (id) deepMutableCopy
{
  return [(id) self deepMutableCopyWithZone: NSDefaultMallocZone ()];
}

@end

#pragma mark -

@implementation NSArray (DeepMutableCopy)

- (id) deepMutableCopyWithZone: (NSZone *) zone
{
  NSMutableArray *mutableCopy = [[NSMutableArray allocWithZone: zone] initWithCapacity: [self count]];
  
  for (unsigned i = 0; i < [self count]; i++)
  {
    id currentObject = [self objectAtIndex: i];
    
    if ([currentObject respondsToSelector: @selector (deepMutableCopyWithZone:)])
    {
      [mutableCopy addObject: [[currentObject deepMutableCopyWithZone: zone] autorelease]];
    }
    else if ([currentObject respondsToSelector: @selector (mutableCopyWithZone)])
    {
      [mutableCopy addObject: [[currentObject mutableCopyWithZone: zone] autorelease]];
    }
    else if ([currentObject respondsToSelector: @selector (copyWithZone)])
    {
      [mutableCopy addObject: [[currentObject copyWithZone: zone] autorelease]];
    }
    else
    {
      [mutableCopy addObject: [currentObject retain]];
    }
  }
  return mutableCopy;
}

@end

#pragma mark -

@implementation NSDictionary (DeepMutableCopy)

- (id) deepMutableCopyWithZone: (NSZone *) zone
{
  NSMutableDictionary *mutableCopy = [[NSMutableDictionary allocWithZone: zone] init];
  id enumerator = [self keyEnumerator];
  id key;
  
  while ((key = [enumerator nextObject]))
  {
    id currentObject = [self objectForKey: key];
    
    if ([currentObject respondsToSelector: @selector (deepMutableCopyWithZone:)])
    {
      [mutableCopy setObject: [[currentObject deepMutableCopyWithZone: zone] autorelease] forKey: key];
    }
    else if ([currentObject respondsToSelector: @selector (mutableCopyWithZone)])
    {
      [mutableCopy setObject: [[currentObject mutableCopyWithZone: zone] autorelease] forKey: key];
    }
    else if ([currentObject respondsToSelector: @selector (copyWithZone)])
    {
      [mutableCopy setObject: [[currentObject copyWithZone: zone] autorelease] forKey: key];
    }
    else
    {
      [mutableCopy setObject: currentObject forKey: key];
    }
  }
  return mutableCopy;
}

@end

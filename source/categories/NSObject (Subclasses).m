//
//  NSObject (Subclasses).m
//  Koan
//
//  Created by Samuel Tesla on 11/25/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "NSObject (Subclasses).h"
#import <objc/objc-runtime.h>

@implementation NSObject (Subclasses)
+ (NSArray *) subclasses;
{
  NSMutableArray * subclasses;
  struct objc_class * superClass;
  Class * classes = NULL;
  Class * current = NULL;
  const Class thisClass = [self class];
  int count, i;
  
  subclasses = [NSMutableArray array];
  
  count = objc_getClassList (NULL, 0);
  if (!count)
    return subclasses;

  classes = malloc (sizeof(Class) * count);
  NSAssert (classes != NULL, @"Memory allocation failed in [NSObject +subclasses]");
  (void) objc_getClassList (classes, count);
  if (!classes)
    return subclasses;
  
  current = classes;
  for (i = 0; i < count; ++i, ++current)
  {
    superClass = *current;
    while (superClass = (superClass)->super_class)
    {
      if (superClass == thisClass)
      {
        [subclasses addObject:*current];
        break;
      }
    }
  }
  
  free (classes);
  
  return subclasses;
}
@end

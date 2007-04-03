//
// NSObject (Subclasses).m
//
// Copyright (c) 2005 3James Software
//
// This file is in the public domain.
//

#import "NSObject (Subclasses).h"
#import <objc/objc-runtime.h>

@implementation NSObject (Subclasses)

+ (NSArray *) subclasses;
{
  NSMutableArray *subclasses = [NSMutableArray array];
  
  int classCount = objc_getClassList (NULL, 0);
  if (classCount == 0)
    return subclasses;

  Class *classes = malloc (sizeof (Class) * classCount);
  NSAssert (classes != NULL, @"Memory allocation failed in [NSObject +subclasses]");
  
  (void) objc_getClassList (classes, classCount);
  if (!classes)
    return subclasses;
  
  Class *current = classes;
  for (unsigned i = 0; i < (unsigned) classCount; i++, current++)
  {
    struct objc_class *superClass = *current;
    while ((superClass = (superClass)->super_class))
    {
      if (superClass == [self class])
      {
        [subclasses addObject: *current];
        break;
      }
    }
  }
  
  free (classes);
  
  return subclasses;
}

@end

//
// NSObject (Subclasses).m
//
// Copyright (c) 2007 3James Software.
//
// License:
// 
//   Permission is hereby granted, free of charge, to any person obtaining a
//   copy of this software and associated documentation files (the "Software"),
//   to deal in the Software without restriction, including without limitation
//   the rights to use, copy, modify, merge, publish, distribute, sublicense,
//   and/or sell copies of the Software, and to permit persons to whom the
//   Software is furnished to do so, subject to the following conditions:
//
//   The above copyright notice and this permission notice shall be included in
//   all copies or substantial portions of the Software.
//
//   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//   FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//   DEALINGS IN THE SOFTWARE.
//

#import "NSObject (Subclasses).h"
#import <objc/objc-runtime.h>

@implementation NSObject (Subclasses)

+ (NSArray *) subclasses
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

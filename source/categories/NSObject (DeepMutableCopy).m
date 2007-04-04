//
// NSObject (DeepMutableCopy).m
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

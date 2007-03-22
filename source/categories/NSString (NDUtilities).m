//
// NSString (NDUtilities).m
//
// Copyright (c) 2002 Nathan Day
// 
// From <http://homepage.mac.com/nathan_day/pages/source.xml>:
// "Some of the source code I've written is available for other developers to
// use, there are really no restrictions on use of this code other than leave
// my name (Nathan Day) within the source code, especially if you make your
// source code public with my code in it."
//
// Copyright (c) 2007 3James Software
//

#import "NSString (NDUtilities).h"

@implementation NSString (NDUtilities)

- (unsigned) indexOfCharacter: (unichar) character range: (NSRange) range
{
  unsigned foundIndex = NSNotFound;
  
  if (range.length + range.location > [self length])
    [NSException raise: NSRangeException format: @"[%@ %@]: Range or index out of bounds",
      NSStringFromClass ([self class]), NSStringFromSelector (_cmd)];
  
  for (unsigned i = range.location; i < range.location + range.length && foundIndex == NSNotFound; i++)
  {
    if ([self characterAtIndex: i] == character)
    {
      foundIndex = i;
      break;
    }
  }
  
  return foundIndex;
}

@end

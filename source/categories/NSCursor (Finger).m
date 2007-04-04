//
// NSCursor (Finger).m
//
// Copyright (c) 2007 3James Software. All rights reserved.
//
// This file is in the public domain.
//

#import "NSCursor (Finger).h"

@implementation NSCursor (Finger)

+ (NSCursor *) fingerCursor;
{
  static NSCursor *fingerCursor = nil;
  
  if (fingerCursor == nil)
  {
    fingerCursor = [[self alloc] initWithImage: [NSImage imageNamed:  @"finger-cursor"]
                                       hotSpot: NSMakePoint (6, 0)];
  }
  
  return fingerCursor;
}

@end

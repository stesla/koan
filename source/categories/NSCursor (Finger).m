//
// NSCursor (Finger).m
//
// Copyright (c) 2005 3James Software
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

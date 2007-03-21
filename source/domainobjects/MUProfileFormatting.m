//
// MUProfileFormatting.m
//
// Copyright (c) 2006 3James Software
//

#import "MUProfileFormatting.h"
#import "MUProfile.h"

@implementation MUProfileFormatting

- (id) initWithProfile: (MUProfile *)newProfile;
{
  if (!(self = [super init]))
    return nil;
  if (!newProfile)
    return nil;
  [self at: &profile put: newProfile];
  return self;
}

#pragma mark -
#pragma mark J3Formatting protocol

- (NSFont *) font
{
  return [profile effectiveFont];
}

- (NSColor *) foreground
{
  if ([profile textColor])
    return [profile textColor];
  else
    return [NSUnarchiver unarchiveObjectWithData: [profile effectiveTextColor]];  
}

- (NSColor *) background
{
  if ([profile backgroundColor])
    return [profile backgroundColor];
  else
    return [NSUnarchiver unarchiveObjectWithData: [profile effectiveBackgroundColor]];  
}

@end

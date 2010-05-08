//
// MUProfileFormatting.m
//
// Copyright (c) 2010 3James Software.
//

#import "MUProfileFormatting.h"
#import "MUProfile.h"

@implementation MUProfileFormatting

- (id) initWithProfile: (MUProfile *) newProfile
{
  if (!(self = [super init]))
    return nil;
  
  profile = [newProfile retain];
  
  return self;
}

- (void) dealloc
{
  [profile release];
  [super dealloc];
}

#pragma mark -
#pragma mark J3Formatter protocol

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

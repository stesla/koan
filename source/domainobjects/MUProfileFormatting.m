//
//  MUProfileFormatting.m
//  Koan
//
//  Created by Samuel on 10/2/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "MUProfileFormatting.h"
#import "MUProfile.h"

@implementation MUProfileFormatting

- (id) initWithProfile:(MUProfile *)newProfile;
{
  if (!(self = [super init]))
    return nil;
  if (!newProfile)
    return nil;
  [self at:&profile put:newProfile];
  return self;
}

#pragma mark -
#pragma mark J3Formatting protocol

- (NSFont *) activeFont;
{
  return [profile effectiveFont];
}

- (NSColor *) foreground;
{
  if ([profile textColor])
    return [profile textColor];
  else
    return [NSUnarchiver unarchiveObjectWithData:[profile effectiveTextColor]];  
}

- (NSColor *) background;
{
  if ([profile backgroundColor])
    return [profile backgroundColor];
  else
    return [NSUnarchiver unarchiveObjectWithData:[profile effectiveBackgroundColor]];  
}

@end

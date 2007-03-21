//
// MUProfileFormatting.h
//
// Copyright (c) 2006 3James Software
//

#import <Cocoa/Cocoa.h>
#import "J3Formatting.h"

@class MUProfile;

@interface MUProfileFormatting : NSObject <J3Formatting>
{
  MUProfile *profile;
}

- (id) initWithProfile: (MUProfile *)newProfile;

@end

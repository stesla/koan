//
// MUProfileFormatting.h
//
// Copyright (c) 2010 3James Software.
//

#import <Cocoa/Cocoa.h>
#import "J3Formatter.h"

@class MUProfile;

@interface MUProfileFormatting : NSObject <J3Formatter>
{
  MUProfile *profile;
}

- (id) initWithProfile: (MUProfile *) newProfile;

@end

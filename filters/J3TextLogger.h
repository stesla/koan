//
// J3TextLogger.h
//
// Copyright (C) 2004, 2005 3James Software
//

#import <Cocoa/Cocoa.h>
#import "J3Filter.h"

@class MUPlayer;
@class MUWorld;

@interface J3TextLogger : J3Filter
{
  NSOutputStream *output;
}

+ (J3Filter *) filterWithWorld:(MUWorld *)world;
+ (J3Filter *) filterWithWorld:(MUWorld *)world player:(MUPlayer *)player;

// Designated initializer.
- (id) initWithOutputStream:(NSOutputStream *)stream;
- (id) initWithWorld:(MUWorld *)world;
- (id) initWithWorld:(MUWorld *)world player:(MUPlayer *)player;

@end

//
// MUTextLogger.h
//
// Copyright (C) 2004 3James Software
//

#import <Cocoa/Cocoa.h>
#import "MUFilter.h"

@class MUPlayer;
@class MUWorld;

@interface MUTextLogger : MUFilter
{
  NSOutputStream *output;
}

+ (id) filterWithWorld:(MUWorld *)world;
+ (id) filterWithWorld:(MUWorld *)world player:(MUPlayer *)player;

// Designated initializer.
- (id) initWithOutputStream:(NSOutputStream *)stream;
- (id) initWithWorld:(MUWorld *)world;
- (id) initWithWorld:(MUWorld *)world player:(MUPlayer *)player;

@end

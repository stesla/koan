//
//  MUProfile.h
//
// Copyright (C) 2004 3James Software
//

#import <Cocoa/Cocoa.h>
#import "MUWorld.h"
#import "MUPlayer.h"

@interface MUProfile : NSObject 
{
  MUWorld   * world;
  MUPlayer  * player;
}

// designated initializer
- (id) initWithWorld:(MUWorld *)world player:(MUPlayer *)player;
- (id) initWithWorld:(MUWorld *)world;

// UI-Related info
- (NSString *) frameName;
- (NSString *) windowName;

// Accessors
- (MUWorld *) world;
- (MUPlayer *) player;
@end

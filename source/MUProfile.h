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
  MUWorld   * profileWorld;
  MUPlayer  * profilePlayer;
}

// designated initializer
- (id) initWithWorld:(MUWorld *)world player:(MUPlayer *)player;
- (id) initWithWorld:(MUWorld *)world;

- (MUWorld *) world;
- (void) setWorld:(MUWorld *)world;
- (MUPlayer *) player;
- (void) setPlayer:(MUPlayer *)player;
@end

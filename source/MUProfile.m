//
//  MUProfile.m
//
// Copyright (C) 2004 3James Software
//

#import "MUProfile.h"

@interface MUProfile (Private)
- (void) setPlayer:(MUPlayer *)player;
- (void) setWorld:(MUWorld *)world;
@end

@implementation MUProfile

- (id) initWithWorld:(MUWorld *)newWorld player:(MUPlayer *)newPlayer
{
  self = [super init];
  if (self && newWorld)
  {
    [self setWorld:newWorld];
    [self setPlayer:newPlayer];
  }
  return self;
}

- (id) initWithWorld:(MUWorld *)newWorld
{
  [self initWithWorld:newWorld player:nil];
}

- (void) dealloc
{
  [player release];
  [world release];
  [super dealloc];
}

- (MUWorld *) world
{
  return world;
}

- (MUPlayer *) player
{
  return player;
}

- (NSString *) frameName
{
  if (player)
    return [player frameName];
  else
    return [world frameName];
}

- (NSString *) windowName
{
  return (player ? [player windowName] : [world windowName]);
}

@end

@implementation MUProfile (Private)
- (void) setWorld:(MUWorld *)newWorld
{
  [newWorld retain];
  [world release];
  world = newWorld;
}

- (void) setPlayer:(MUPlayer *)newPlayer
{
  [newPlayer retain];
  [player release];
  player = newPlayer;
}
@end

//
//  MUProfile.m
//
// Copyright (C) 2004 3James Software
//

#import "MUProfile.h"


@implementation MUProfile

- (id) initWithWorld:(MUWorld *)world player:(MUPlayer *)player
{
  self = [super init];
  if (self && world)
  {
    [self setWorld:world];
    [self setPlayer:player];
  }
  return self;
}

- (id) initWithWorld:(MUWorld *)world
{
  [self initWithWorld:world player:nil];
}

- (void) dealloc
{
  [profilePlayer release];
  [profileWorld release];
  [super dealloc];
}

- (MUWorld *) world
{
  return profileWorld;
}

- (void) setWorld:(MUWorld *)world
{
  [world retain];
  [profileWorld release];
  profileWorld = world;
}

- (MUPlayer *) player
{
  return profilePlayer;
}

- (void) setPlayer:(MUPlayer *)player
{
  [player retain];
  [profilePlayer release];
  profilePlayer = player;
}
@end

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
  if (self)
  {
    [self setWorld:world];
    [self setPlayer:player];
  }
  return self;
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

//
//  MUProfile.m
//
// Copyright (C) 2004 3James Software
//

#import "MUProfile.h"
#import "J3TextLogger.h"

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

- (NSString *) loginString
{
  return [player loginString];
}

- (J3Filter *) logger
{
  if (player)
    return [J3TextLogger filterWithWorld:world player:player];
  else
    return [J3TextLogger filterWithWorld:world];
}

- (NSString *) hostname;
{
  return [world worldHostname];
}

- (J3TelnetConnection *) openTelnetWithDelegate:(id)aDelegate
{
  J3TelnetConnection  * telnet = [world newTelnetConnection];
  
  if (telnet)
  {
    [telnet setDelegate:aDelegate];
    [telnet open];
  }  
  
  return telnet;
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

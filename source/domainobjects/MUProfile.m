//
// MUProfile.m
//
// Copyright (C) 2004, 2005 3James Softwareautoconnect
//

#import "MUProfile.h"
#import "J3TextLogger.h"

@implementation MUProfile

+ (MUProfile *) profileWithWorld:(MUWorld *)newWorld 
                          player:(MUPlayer *)newPlayer
                     autoconnect:(BOOL)newAutoconnect
{
  return [[[self alloc] initWithWorld:newWorld
                               player:newPlayer
                          autoconnect:newAutoconnect] autorelease];
}

+ (MUProfile *) profileWithWorld:(MUWorld *)newWorld player:(MUPlayer *)newPlayer
{
  return [[[self alloc] initWithWorld:newWorld 
                               player:newPlayer] autorelease];
}

+ (MUProfile *) profileWithWorld:(MUWorld *)newWorld
{
  return [[[self alloc] initWithWorld:newWorld] autorelease];
}

- (id) initWithWorld:(MUWorld *)newWorld player:(MUPlayer *)newPlayer
{
  return [self initWithWorld:newWorld 
                      player:newPlayer 
                 autoconnect:NO];
}

- (id) initWithWorld:(MUWorld *)newWorld 
              player:(MUPlayer *)newPlayer
         autoconnect:(BOOL)newAutoconnect
{
  self = [super init];
  if (self && newWorld)
  {
    [self setWorld:newWorld];
    [self setPlayer:newPlayer];
    [self setAutoconnect:newAutoconnect];
  }
  return self;
}

- (id) initWithWorld:(MUWorld *)newWorld
{
  return [self initWithWorld:newWorld player:nil];
}

- (void) dealloc
{
  [player release];
  [world release];
  [super dealloc];
}

#pragma mark -
#pragma mark Accessors

- (MUWorld *) world
{
  return world;
}

- (void) setWorld:(MUWorld *)newWorld
{
  [newWorld retain];
  [world release];
  world = newWorld;
}

- (MUPlayer *) player
{
  return player;
}

- (void) setPlayer:(MUPlayer *)newPlayer
{
  [newPlayer retain];
  [player release];
  player = newPlayer;
}

- (BOOL) autoconnect
{
  return autoconnect;
}

- (void) setAutoconnect:(BOOL)newAutoconnect
{
  autoconnect = newAutoconnect;
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

- (J3TelnetConnection *) openTelnetWithDelegate:(id)delegate
{
  J3TelnetConnection *telnet = [world newTelnetConnection];
  
  if (telnet)
  {
    [telnet setDelegate:delegate];
    [telnet open];
  }  
  
  return telnet;
}

- (void) loginWithConnection:(J3TelnetConnection *)connection
{
  if (!loggedIn && player)
  {
    [connection sendLine:[player loginString]];
    loggedIn = YES;
  }
}

- (void) logoutWithConnection:(J3TelnetConnection *)connection
{
  // We don't do anything with the connection at this point, but we could.
  // I put it there for parallelism with -loginWithConnection: and to make it
  // easy to add any shutdown we may decide we need later.
  loggedIn = NO;
}

- (NSString *) uniqueIdentifier
{
  NSString *rval = nil;
  if (player)
  {
    // Consider offloading the generation of a unique name for the player on
    // MUPlayer.
    rval = [NSString stringWithFormat:@"%@.%@", 
      [world uniqueIdentifier], [[player name] lowercaseString]];
  }
  else
  {
    rval = [world uniqueIdentifier];
  }
  return rval;
}

@end

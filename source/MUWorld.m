//
// MUWorld.m
//
// Copyright (C) 2004 3James Software
//

#import "MUWorld.h"

static const int32_t currentVersion = 0;

@implementation MUWorld

- (id) initWithWorldName:(NSString *)newWorldName
           worldHostname:(NSString *)newWorldHostname
               worldPort:(NSNumber *)newWorldPort
{
  if (self = [super init])
  {
    [self setWorldName:newWorldName];
    [self setWorldHostname:newWorldHostname];
    [self setWorldPort:newWorldPort];
  }
  return self;
}

- (id) init
{
  return [self initWithWorldName:NSLocalizedString (MULUntitledWorld, nil)
                   worldHostname:@""
                       worldPort:[NSNumber numberWithInt:0]];
}

#pragma mark -
#pragma mark Accessors

- (NSString *) worldName
{
  return worldName;
}

- (void) setWorldName:(NSString *)newWorldName
{
  NSString *copy = [newWorldName copy];
  [worldName release];
  worldName = copy;
}

- (NSString *) worldHostname
{
  return worldHostname;
}

- (void) setWorldHostname:(NSString *)newWorldHostname
{
  NSString *copy = [newWorldHostname copy];
  [worldHostname release];
  worldHostname = copy;
}

- (NSNumber *) worldPort
{
  return worldPort;
}

- (void) setWorldPort:(NSNumber *)newWorldPort
{
  NSNumber *copy = [newWorldPort copy];
  [worldPort release];
  worldPort = copy;
}


- (NSDictionary *) players
{
  return players;
}

- (void) setPlayers:(NSDictionary *)newPlayers
{
  NSDictionary *copy = [newPlayers copy];
  [players release];
  players = copy;
}

#pragma mark -
#pragma mark Actions

- (J3TelnetConnection *) newTelnetConnection
{
  return [[J3TelnetConnection alloc] initWithHostName:[self worldHostname]
                                               onPort:[[self worldPort] intValue]];
}

#pragma mark -
#pragma mark NSCoding protocol

- (void) encodeWithCoder:(NSCoder *)encoder
{
  [encoder encodeInt32:currentVersion forKey:@"version"];
  
  [encoder encodeObject:[self worldName] forKey:@"worldName"];
  [encoder encodeObject:[self worldHostname] forKey:@"worldHostname"];
  [encoder encodeObject:[self worldPort] forKey:@"worldPort"];
}

- (id) initWithCoder:(NSCoder *)decoder
{
  if (self = [super init])
  {
    int32_t version = [decoder decodeInt32ForKey:@"version"];
    
    [self setWorldName:[decoder decodeObjectForKey:@"worldName"]];
    [self setWorldHostname:[decoder decodeObjectForKey:@"worldHostname"]];
    [self setWorldPort:[decoder decodeObjectForKey:@"worldPort"]];
  }
  return self;
}

#pragma mark -
#pragma mark NSCopying protocol

- (id) copyWithZone:(NSZone *)zone
{
  return [[MUWorld allocWithZone:zone] initWithWorldName:[self worldName]
                                           worldHostname:[self worldHostname]
                                               worldPort:[self worldPort]];
}

@end

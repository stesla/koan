//
// MUWorld.m
//
// Copyright (C) 2004 3James Software
//

#import "MUWorld.h"

#import <J3Terminal/J3TelnetConnection.h>

static const int32_t currentVersion = 1;

@interface MUWorld (Private)

- (void) postWorldsUpdatedNotification;

@end

#pragma mark -

@implementation MUWorld

- (id) initWithWorldName:(NSString *)newWorldName
           worldHostname:(NSString *)newWorldHostname
               worldPort:(NSNumber *)newWorldPort
                worldURL:(NSString *)newWorldURL
        connectOnAppLaunch:(BOOL)newConnectOnAppLaunch
                 players:(NSArray *)newPlayers
{
  if (self = [super init])
  {
    [self setWorldName:newWorldName];
    [self setWorldHostname:newWorldHostname];
    [self setWorldPort:newWorldPort];
    [self setWorldURL:newWorldURL];
    [self setConnectOnAppLaunch:newConnectOnAppLaunch];
    [self setPlayers:newPlayers];
  }
  return self;
}

- (id) init
{
  return [self initWithWorldName:@""
                   worldHostname:@""
                       worldPort:[NSNumber numberWithInt:0]
                        worldURL:@""
                connectOnAppLaunch:NO
                         players:[NSArray array]];
}

- (void) dealloc
{
  [worldName release];
  [worldHostname release];
  [worldPort release];
  [worldURL release];
  [players release];
  [super dealloc];
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

- (NSString *) worldURL
{
  return worldURL;
}

- (void) setWorldURL:(NSString *)newWorldURL
{
  NSString *copy = [newWorldURL copy];
  [worldURL release];
  worldURL = copy;
}

- (BOOL) connectOnAppLaunch
{
  return connectOnAppLaunch;
}

- (void) setConnectOnAppLaunch:(BOOL)newConnectOnAppLaunch
{
  connectOnAppLaunch = newConnectOnAppLaunch;
}

- (NSMutableArray *) players
{
  return players;
}

- (void) setPlayers:(NSArray *)newPlayers
{
  NSSortDescriptor *sortDesc = [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease];
  NSMutableArray *copy = [[newPlayers sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDesc]] mutableCopy];
  
  [players release];
  players = copy;
  [self postWorldsUpdatedNotification];
}

- (void) insertObject:(MUPlayer *)player inPlayersAtIndex:(unsigned)index
{
  NSSortDescriptor *sortDesc = [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease];
  
  [players insertObject:player atIndex:index];
  [players sortUsingDescriptors:[NSArray arrayWithObject:sortDesc]];
  [self postWorldsUpdatedNotification];
}

- (void) removeObjectFromPlayersAtIndex:(unsigned)index
{
  [players removeObjectAtIndex:index];
  [self postWorldsUpdatedNotification];
}

#pragma mark -
#pragma mark Actions

- (J3TelnetConnection *) newTelnetConnection
{
  return [[J3TelnetConnection alloc] initWithHostName:[self worldHostname]
                                               onPort:[[self worldPort] intValue]];
}

- (NSString *) frameName
{
  return [NSString stringWithFormat:@"%@.%@", [self worldHostname], [self worldPort]];
}

- (NSString *) windowName
{
  return [NSString stringWithFormat:@"%@", [self worldName]];
}

#pragma mark -
#pragma mark NSCoding protocol

- (void) encodeWithCoder:(NSCoder *)encoder
{
  [encoder encodeInt32:currentVersion forKey:@"version"];
  
  [encoder encodeObject:[self worldName] forKey:@"worldName"];
  [encoder encodeObject:[self worldHostname] forKey:@"worldHostname"];
  [encoder encodeObject:[self worldPort] forKey:@"worldPort"];
  [encoder encodeObject:[self players] forKey:@"players"];
  
  [encoder encodeObject:[self worldURL] forKey:@"worldURL"];
  [encoder encodeBool:[self connectOnAppLaunch] forKey:@"connectOnAppLaunch"];
}

- (id) initWithCoder:(NSCoder *)decoder
{
  if (self = [super init])
  {
    int32_t version = [decoder decodeInt32ForKey:@"version"];
    
    [self setWorldName:[decoder decodeObjectForKey:@"worldName"]];
    [self setWorldHostname:[decoder decodeObjectForKey:@"worldHostname"]];
    [self setWorldPort:[decoder decodeObjectForKey:@"worldPort"]];
    [self setPlayers:[decoder decodeObjectForKey:@"players"]];
    
    if (version >= 1)
    {
      [self setWorldURL:[decoder decodeObjectForKey:@"worldURL"]];
      [self setConnectOnAppLaunch:[decoder decodeBoolForKey:@"connectOnAppLaunch"]];
    }
    else
    {
      [self setWorldURL:@""];
      [self setConnectOnAppLaunch:NO];
    }
  }
  return self;
}

#pragma mark -
#pragma mark NSCopying protocol

- (id) copyWithZone:(NSZone *)zone
{
  return [[MUWorld allocWithZone:zone] initWithWorldName:[self worldName]
                                           worldHostname:[self worldHostname]
                                               worldPort:[self worldPort]
                                                worldURL:[self worldURL]
                                        connectOnAppLaunch:[self connectOnAppLaunch]
                                                 players:[self players]];
}

@end

#pragma mark -

@implementation MUWorld (Private)

- (void) postWorldsUpdatedNotification
{
  [[NSNotificationCenter defaultCenter] postNotificationName:MUWorldsUpdatedNotification
                                                      object:self];
}

@end

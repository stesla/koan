//
// MUWorld.m
//
// Copyright (c) 2007 3James Software.
//

#import "J3SocketFactory.h"
#import "MUWorld.h"
#import "MUConstants.h"
#import "MUPlayer.h"
#import "MUCodingService.h"

@interface MUWorld (Private)

- (void) postWorldsDidChangeNotification;

@end

#pragma mark -

@implementation MUWorld

@synthesize name, hostname, port, url;

+ (MUWorld *) worldWithName: (NSString *) newName
  								 hostname: (NSString *) newHostname
  										 port: (NSNumber *) newPort
  											URL: (NSString *) newURL
  									players: (NSArray *) newPlayers
{
  return [[[self alloc] initWithName: newName
  													hostname: newHostname
  															port: newPort
  															 URL: newURL
  													 players: newPlayers] autorelease];
}

- (id) initWithName: (NSString *) newName
           hostname: (NSString *) newHostname
               port: (NSNumber *) newPort
                URL: (NSString *) newURL
            players: (NSArray *) newPlayers
{
  if (![super init])
    return nil;
  
  self.name = newName;
  self.hostname = newHostname;
  self.port = newPort;
  self.url = newURL;
  [self setPlayers: (newPlayers ? newPlayers : [NSArray array])];
  
  return self;
}

- (id) init
{
  return [self initWithName: @""
                   hostname: @""
                       port: [NSNumber numberWithInt: 0]
                        URL: @""
                    players: nil];
}

- (void) dealloc
{
  [name release];
  [hostname release];
  [port release];
  [url release];
  [players release];
  [super dealloc];
}

#pragma mark -
#pragma mark Array-like accessors for players

- (NSMutableArray *) players
{
  return players;
}

- (void) setPlayers: (NSArray *) newPlayers
{
  if (players == newPlayers)
    return;
  [players release];
  players = [newPlayers mutableCopy];
  [self postWorldsDidChangeNotification];
}

- (int) indexOfPlayer: (MUPlayer *) player
{
  for (unsigned i = 0; i < [players count]; i++)
  {
  	if (player == [players objectAtIndex: i])
  		return (int) i;
  }
  
  return NSNotFound;
}

- (void) insertObject: (MUPlayer *) player inPlayersAtIndex: (unsigned) playerIndex
{
  [players insertObject: player atIndex: playerIndex];
  [self postWorldsDidChangeNotification];
}

- (void) removeObjectFromPlayersAtIndex: (unsigned) playerIndex
{
  [players removeObjectAtIndex: playerIndex];
  [self postWorldsDidChangeNotification];
}

- (void) addPlayer: (MUPlayer *) player
{
  if ([self containsPlayer: player])
    return;
  
  [players addObject: player];
  player.world = self;
  [self postWorldsDidChangeNotification];
}

- (BOOL) containsPlayer: (MUPlayer *) player
{
  return [players containsObject: player];
}

- (void) removePlayer: (MUPlayer *) player
{
  player.world = nil;
  [players removeObject: player];
  [self postWorldsDidChangeNotification];
}

- (void) replacePlayer: (MUPlayer *) oldPlayer withPlayer: (MUPlayer *) newPlayer
{
  for (unsigned i = 0; i < [players count]; i++)
  {
  	MUPlayer *player = [players objectAtIndex: i];
  	
  	if (player != oldPlayer)
      continue;
    
    [players replaceObjectAtIndex: i withObject: newPlayer];
    oldPlayer.world = nil;
    newPlayer.world = self;
    [self postWorldsDidChangeNotification];
    break;
  }
}

#pragma mark -
#pragma mark Actions

- (J3TelnetConnection *) newTelnetConnectionWithDelegate: (NSObject <J3ConnectionDelegate> *) delegate
{
  return [J3TelnetConnection telnetWithHostname: self.hostname port: [self.port intValue] delegate: delegate];
}

- (NSString *) uniqueIdentifier
{
  NSArray *tokens = [self.name componentsSeparatedByString: @" "];
  NSMutableString *result = [NSMutableString string];

  if ([tokens count] > 0)
  {
    [result appendFormat: @"%@", [[tokens objectAtIndex: 0] lowercaseString]];
    
    for (unsigned i = 1; i < [tokens count]; i++)
      [result appendFormat: @".%@", [[tokens objectAtIndex: i] lowercaseString]];
  }
  return result;
}

- (NSString *) windowTitle
{
  return [NSString stringWithFormat: @"%@", self.name];
}

#pragma mark -
#pragma mark NSCoding protocol

- (void) encodeWithCoder: (NSCoder *) encoder
{
  [MUCodingService encodeWorld: self withCoder: encoder];
}

- (id) initWithCoder: (NSCoder *) decoder
{
  if (![super init])
    return nil;
  
  [MUCodingService decodeWorld: self withCoder: decoder];
  return self;
}

#pragma mark -
#pragma mark NSCopying protocol

- (id) copyWithZone: (NSZone *) zone
{
  return [[MUWorld allocWithZone: zone] initWithName: self.name
                                            hostname: self.hostname
                                                port: self.port
                                                 URL: self.url
                                             players: [self players]];
}

@end

#pragma mark -

@implementation MUWorld (Private)

- (void) postWorldsDidChangeNotification
{
  [[NSNotificationCenter defaultCenter] postNotificationName: MUWorldsDidChangeNotification
                                                      object: self];
}

@end

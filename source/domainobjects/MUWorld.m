//
// MUWorld.m
//
// Copyright (c) 2004, 2005 3James Software
//

#import "J3Telnet.h"
#import "MUWorld.h"
#import "MUConstants.h"
#import "MUPlayer.h"
#import "MUCodingService.h"

@interface MUWorld (Private)

- (void) postWorldsDidChangeNotification;

@end

#pragma mark -

@implementation MUWorld

- (id) initWithWorldName:(NSString *)newWorldName
           worldHostname:(NSString *)newWorldHostname
               worldPort:(NSNumber *)newWorldPort
                worldURL:(NSString *)newWorldURL
                 players:(NSArray *)newPlayers
{
  if (![super init])
    return nil;
  [self setWorldName:newWorldName];
  [self setWorldHostname:newWorldHostname];
  [self setWorldPort:newWorldPort];
  [self setWorldURL:newWorldURL];
  [self setPlayers:newPlayers];
  if (![self players])
    [self setPlayers:[NSArray array]];
  return self;
}

- (id) init
{
  return [self initWithWorldName:@""
                   worldHostname:@""
                       worldPort:[NSNumber numberWithInt:0]
                        worldURL:@""
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

- (NSMutableArray *) players
{
  return players;
}

- (void) setPlayers:(NSArray *)newPlayers
{
  NSMutableArray *copy = [newPlayers mutableCopy];
  
  [players release];
  players = copy;
  [self postWorldsDidChangeNotification];
}

- (int) indexOfPlayer:(MUPlayer *)player
{
	unsigned i, playersCount = [players count];
	
	for (i = 0; i < playersCount; i++)
	{
		MUPlayer *iteratedPlayer = [players objectAtIndex:i];
		
		if (player == iteratedPlayer)
		{
			return (int) i;
		}
	}
	
	return -1;
}

- (void) insertObject:(MUPlayer *)player inPlayersAtIndex:(unsigned)index
{
  [players insertObject:player atIndex:index];
  [self postWorldsDidChangeNotification];
}

- (void) removeObjectFromPlayersAtIndex:(unsigned)index
{
  [players removeObjectAtIndex:index];
  [self postWorldsDidChangeNotification];
}

- (void) addPlayer:(MUPlayer *)player
{
  if (![self containsPlayer:player])
  {
    [players addObject:player];
    [player setWorld:self];
		[self postWorldsDidChangeNotification];
  }
}

- (BOOL) containsPlayer:(MUPlayer *)player
{
  return [players containsObject:player];
}

- (void) removePlayer:(MUPlayer *)player
{
  [player setWorld:nil];
  [players removeObject:player];
	[self postWorldsDidChangeNotification];
}

- (void) replacePlayer:(MUPlayer *)oldPlayer withPlayer:(MUPlayer *)newPlayer
{
	unsigned i, playersCount = [players count];
	
	for (i = 0; i < playersCount; i++)
	{
		MUPlayer *player = [players objectAtIndex:i];
		
		if (player == oldPlayer)
		{
			[players replaceObjectAtIndex:i withObject:newPlayer];
			[self postWorldsDidChangeNotification];
			break;
		}
	}
}

#pragma mark -
#pragma mark Actions

- (J3Telnet *) newTelnetConnectionWithDelegate:(NSObject <J3LineBufferDelegate, J3TelnetConnectionDelegate> *)delegate
{
  return [J3Telnet lineAtATimeTelnetWithHostname:[self worldHostname]
                                            port:[[self worldPort] intValue]
                                        delegate:delegate
                              lineBufferDelegate:delegate];
}

- (NSString *) uniqueIdentifier
{
  NSArray *tokens = [worldName componentsSeparatedByString:@" "];
  NSMutableString *result = [NSMutableString string];
  if ([tokens count] > 0)
  {
    int i = 0;
    [result appendFormat:@"%@", [[tokens objectAtIndex:i] lowercaseString]];
    for (i = 1; i < [tokens count]; i++)
      [result appendFormat:@".%@", [[tokens objectAtIndex:i] lowercaseString]];
  }
  return result;
}

- (NSString *) windowTitle
{
  return [NSString stringWithFormat:@"%@", [self worldName]];
}

#pragma mark -
#pragma mark NSCoding protocol

- (void) encodeWithCoder:(NSCoder *)encoder
{
  [MUCodingService encodeWorld:self withCoder:encoder];
}

- (id) initWithCoder:(NSCoder *)decoder
{
  if (self = [super init])
    [MUCodingService decodeWorld:self withCoder:decoder];
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
                                                 players:[self players]];
}

@end

#pragma mark -

@implementation MUWorld (Private)

- (void) postWorldsDidChangeNotification
{
  [[NSNotificationCenter defaultCenter] postNotificationName:MUWorldsDidChangeNotification
                                                      object:self];
}

@end

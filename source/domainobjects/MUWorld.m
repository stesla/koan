//
// MUWorld.m
//
// Copyright (c) 2004, 2005 3James Software
//

#import <J3Terminal/J3TelnetConnection.h>
#import "MUWorld.h"
#import "MUConstants.h"
#import "MUPlayer.h"
#import "MUCodingService.h"

@interface MUWorld (Private)
- (void) postWorldsUpdatedNotification;
@end

#pragma mark -

@implementation MUWorld

- (id) initWithWorldName:(NSString *)newWorldName
           worldHostname:(NSString *)newWorldHostname
               worldPort:(NSNumber *)newWorldPort
                worldURL:(NSString *)newWorldURL
                 usesSSL:(BOOL)newUsesSSL
           proxySettings:(J3ProxySettings *)newProxySettings
                 players:(NSArray *)newPlayers
{
  if (self = [super init])
  {
    [self setWorldName:newWorldName];
    [self setWorldHostname:newWorldHostname];
    [self setWorldPort:newWorldPort];
    [self setWorldURL:newWorldURL];
    [self setUsesSSL:newUsesSSL];
    [self setProxySettings:newProxySettings];
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
                         usesSSL:NO
                   proxySettings:nil
                         players:[NSArray array]];
}

- (void) dealloc
{
  [worldName release];
  [worldHostname release];
  [worldPort release];
  [worldURL release];
  [proxySettings release];
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

- (BOOL) usesSSL
{
  return usesSSL;
}

- (void) setUsesSSL:(BOOL)newUsesSSL
{
  usesSSL = newUsesSSL;
}

- (J3ProxySettings *) proxySettings
{
  return proxySettings;
}

- (void) setProxySettings:(J3ProxySettings *)newProxySettings
{
  [newProxySettings retain];
  [proxySettings release];
  proxySettings = newProxySettings;
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

- (void) addPlayer:(MUPlayer *)player
{
  if (![self containsPlayer:player])
  {
    [players addObject:player];
    [player setWorld:self];
		[self postWorldsUpdatedNotification];
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
	[self postWorldsUpdatedNotification];
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
			[self postWorldsUpdatedNotification];
			break;
		}
	}
}

#pragma mark -
#pragma mark Actions

- (J3TelnetConnection *) newTelnetConnection
{
  J3TelnetConnection * telnet;
  telnet = [[J3TelnetConnection alloc] 
    initWithHostName:[self worldHostname]
              onPort:[[self worldPort] intValue]]; //TODO: Autorelease?

  if ([self usesSSL])
    [telnet setSecurityLevel:NSStreamSocketSecurityLevelNegotiatedSSL];
  
  if (proxySettings)
    [telnet enableProxyWithSettings:proxySettings];
  
  return telnet;
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
                                                 usesSSL:[self usesSSL]
                                           proxySettings:[self proxySettings]
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

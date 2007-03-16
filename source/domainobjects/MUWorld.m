//
// MUWorld.m
//
// Copyright (c) 2004, 2005, 2006, 2007 3James Software
//

#import "J3ConnectionFactory.h"
#import "MUWorld.h"
#import "MUConstants.h"
#import "MUPlayer.h"
#import "MUCodingService.h"

@interface MUWorld (Private)

- (void) postWorldsDidChangeNotification;

@end

#pragma mark -

@implementation MUWorld

+ (MUWorld *) worldWithName:(NSString *)newName
									 hostname:(NSString *)newHostname
											 port:(NSNumber *)newPort
												URL:(NSString *)newURL
										players:(NSArray *)newPlayers
{
	return [[[self alloc] initWithName:newName
														hostname:newHostname
																port:newPort
																 URL:newURL
														 players:newPlayers] autorelease];
}

- (id) initWithName:(NSString *)newName
           hostname:(NSString *)newHostname
               port:(NSNumber *)newPort
                URL:(NSString *)newURL
            players:(NSArray *)newPlayers
{
  if (![super init])
    return nil;
  
  [self setName:newName];
  [self setHostname:newHostname];
  [self setPort:newPort];
  [self setURL:newURL];
  [self setPlayers:(newPlayers ? newPlayers : [NSArray array])];
  
  return self;
}

- (id) init
{
  return [self initWithName:@""
                   hostname:@""
                       port:[NSNumber numberWithInt:0]
                        URL:@""
                    players:nil];
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
#pragma mark Accessors

- (NSString *) name
{
  return name;
}

- (void) setName:(NSString *)newName
{
  if (name == newName)
    return;
  [name release];
  name = [newName copy];
}

- (NSString *) hostname
{
  return hostname;
}

- (void) setHostname:(NSString *)newHostname
{
  if (hostname == newHostname)
    return;
  [hostname release];
  hostname = [newHostname copy];
}

- (NSNumber *) port
{
  return port;
}

- (void) setPort:(NSNumber *)newPort
{
  if (port == newPort)
    return;
  [port release];
  port = [newPort copy];
}

- (NSString *) URL
{
  return url;
}

- (void) setURL:(NSString *)newURL
{
  if (url == newURL)
    return;
  [url release];
  url = [newURL copy];
}

- (NSMutableArray *) players
{
  return players;
}

- (void) setPlayers:(NSArray *)newPlayers
{
  if (players == newPlayers)
    return;
  [players release];
  players = [newPlayers mutableCopy];
  [self postWorldsDidChangeNotification];
}

- (int) indexOfPlayer:(MUPlayer *)player
{
	unsigned i;
	
	for (i = 0; i < [players count]; i++)
	{
		MUPlayer *iteratedPlayer = [players objectAtIndex:i];
		
		if (player == iteratedPlayer)
			return (int) i;
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
  if ([self containsPlayer:player])
    return;
  
  [players addObject:player];
  [player setWorld:self];
  [self postWorldsDidChangeNotification];
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
	unsigned i;
	
	for (i = 0; i < [players count]; i++)
	{
		MUPlayer *player = [players objectAtIndex:i];
		
		if (player != oldPlayer)
      continue;
    
    [players replaceObjectAtIndex:i withObject:newPlayer];
    [self postWorldsDidChangeNotification];
    break;
	}
}

#pragma mark -
#pragma mark Actions

- (J3Telnet *) newTelnetConnectionWithDelegate:(NSObject <J3LineBufferDelegate, J3TelnetConnectionDelegate> *)delegate
{
  return [[J3ConnectionFactory defaultFactory] lineAtATimeTelnetWithHostname:[self hostname] port:[[self port] intValue] delegate:delegate lineBufferDelegate:delegate];
}

- (NSString *) uniqueIdentifier
{
  NSArray *tokens = [[self name] componentsSeparatedByString:@" "];
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
  return [NSString stringWithFormat:@"%@", [self name]];
}

#pragma mark -
#pragma mark NSCoding protocol

- (void) encodeWithCoder:(NSCoder *)encoder
{
  [MUCodingService encodeWorld:self withCoder:encoder];
}

- (id) initWithCoder:(NSCoder *)decoder
{
  if (![super init])
    return nil;
  
  [MUCodingService decodeWorld:self withCoder:decoder];
  return self;
}

#pragma mark -
#pragma mark NSCopying protocol

- (id) copyWithZone:(NSZone *)zone
{
  return [[MUWorld allocWithZone:zone] initWithName:[self name]
                                           hostname:[self hostname]
                                               port:[self port]
                                                URL:[self URL]
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

//
// MUWorld.m
//
// Copyright (C) 2004 3James Software
//

#import "MUWorld.h"
#import "MUConstants.h"
#import "MUPlayer.h"

#import <J3Terminal/J3TelnetConnection.h>

static const int32_t currentVersion = 2;

@interface MUWorld (Private)
- (void) postWorldsUpdatedNotification;
@end

@interface MUWorld (CodingHelpers)
- (void) decodeProxySettingsWithCoder:(NSCoder *)decoder version:(int)version;
@end

#pragma mark -

@implementation MUWorld

- (id) initWithWorldName:(NSString *)newWorldName
           worldHostname:(NSString *)newWorldHostname
               worldPort:(NSNumber *)newWorldPort
                worldURL:(NSString *)newWorldURL
      connectOnAppLaunch:(BOOL)newConnectOnAppLaunch
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
    [self setConnectOnAppLaunch:newConnectOnAppLaunch];
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
              connectOnAppLaunch:NO
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

- (BOOL) connectOnAppLaunch
{
  return connectOnAppLaunch;
}

- (void) setConnectOnAppLaunch:(BOOL)newConnectOnAppLaunch
{
  connectOnAppLaunch = newConnectOnAppLaunch;
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
  }
}

- (BOOL) containsPlayer:(MUPlayer *)player
{
  [players containsObject:player];
}

- (void) removePlayer:(MUPlayer *)player
{
  [players removeObject:player];
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
  
  [encoder encodeBool:[self usesSSL] forKey:@"usesSSL"];
  
  [encoder encodeBool:(proxySettings == nil) forKey:@"usesProxy"];
  [encoder encodeObject:[proxySettings hostname] forKey:@"proxyHostname"];
  [encoder encodeObject:[NSNumber numberWithInt:[proxySettings port]] forKey:@"proxyPort"];
  [encoder encodeInt:[proxySettings version] forKey:@"proxyVersion"];
  [encoder encodeObject:[proxySettings username] forKey:@"proxyUsername"];
  [encoder encodeObject:[proxySettings password] forKey:@"proxyPassword"];  
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
    
    if (version >= 2)
      [self setUsesSSL:[decoder decodeBoolForKey:@"usesSSL"]];
    else
      [self setUsesSSL:NO];
    
    [self decodeProxySettingsWithCoder:decoder version:version];
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

@implementation MUWorld (CodingHelpers)
- (void) decodeProxySettingsWithCoder:(NSCoder *)decoder version:(int)version
{
  NSString *hostname = nil, *username = nil, *password = nil;
  NSNumber *port = [NSNumber numberWithInt:0];
  int newProxyVersion = 5;
  
  if (version == 2)
  {
    [decoder decodeBoolForKey:@"usesProxy"];
    hostname = [decoder decodeObjectForKey:@"proxyHostname"];
    port = [decoder decodeObjectForKey:@"proxyPort"];
    newProxyVersion = [decoder decodeIntForKey:@"proxyVersion"];
    username = [decoder decodeObjectForKey:@"proxyUsername"];
    password = [decoder decodeObjectForKey:@"proxyPassword"];
  }

  // If this came out nil, then something isn't kosher
  if (!port)
    return;
    
  [self setProxySettings:[[J3ProxySettings alloc]
      initWithHostname:hostname
                  port:[port intValue]
               version:newProxyVersion
              username:username
              password:password]];
}
@end

//
// MUWorld.m
//
// Copyright (C) 2004, 2005 3James Software
//

#import "MUWorld.h"
#import "MUConstants.h"
#import "MUPlayer.h"

#import <J3Terminal/J3TelnetConnection.h>

static const int32_t currentVersion = 3;

@interface MUWorld (Private)
- (void) postWorldsUpdatedNotification;
@end

@interface MUWorld (CodingHelpers)
+ (J3ProxySettings *) decodeProxySettingsWithCoder:(NSCoder *)decoder
                                           version:(int)version;
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
  [MUWorld encodeWorld:self withCoder:encoder];
}

- (id) initWithCoder:(NSCoder *)decoder
{
  if (self = [super init])
    [MUWorld decodeWorld:self withCoder:decoder];
  return self;
}

+ (void) encodeWorld:(MUWorld *)world withCoder:(NSCoder *)encoder
{
  J3ProxySettings *theProxySettings = [world proxySettings];
  [encoder encodeInt32:currentVersion forKey:@"version"];
  
  [encoder encodeObject:[world worldName] forKey:@"worldName"];
  [encoder encodeObject:[world worldHostname] forKey:@"worldHostname"];
  [encoder encodeObject:[world worldPort] forKey:@"worldPort"];
  [encoder encodeObject:[world players] forKey:@"players"];
  [encoder encodeObject:[world worldURL] forKey:@"worldURL"];
  [encoder encodeBool:[world usesSSL] forKey:@"usesSSL"];
  [encoder encodeObject:[theProxySettings hostname] forKey:@"proxyHostname"];
  [encoder encodeObject:[NSNumber numberWithInt:[theProxySettings port]] forKey:@"proxyPort"];
  [encoder encodeInt:[theProxySettings version] forKey:@"proxyVersion"];
  [encoder encodeObject:[theProxySettings username] forKey:@"proxyUsername"];
  [encoder encodeObject:[theProxySettings password] forKey:@"proxyPassword"];   
}

+ (void) decodeWorld:(MUWorld *)world withCoder:(NSCoder *)decoder
{
  int32_t version = [decoder decodeInt32ForKey:@"version"];
  
  [world setWorldName:[decoder decodeObjectForKey:@"worldName"]];
  [world setWorldHostname:[decoder decodeObjectForKey:@"worldHostname"]];
  [world setWorldPort:[decoder decodeObjectForKey:@"worldPort"]];
  [world setPlayers:[decoder decodeObjectForKey:@"players"]];
  
  if (version >= 1)
  {
    [world setWorldURL:[decoder decodeObjectForKey:@"worldURL"]];
    if (version < 3)
      [decoder decodeBoolForKey:@"connectOnAppLaunch"];
  }
  else
  {
    [world setWorldURL:@""];
  }
  
  if (version >= 2)
    [world setUsesSSL:[decoder decodeBoolForKey:@"usesSSL"]];
  else
    [world setUsesSSL:NO];
  
  [world setProxySettings:[self decodeProxySettingsWithCoder:decoder 
                                                     version:version]];  
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

@implementation MUWorld (CodingHelpers)
+ (J3ProxySettings *) decodeProxySettingsWithCoder:(NSCoder *)decoder version:(int)version
{
  NSString *hostname = nil, *username = nil, *password = nil;
  NSNumber *port = [NSNumber numberWithInt:0];
  int newProxyVersion = 5;
  
  if (version >= 2)
  {
    if (version == 2)
      [decoder decodeBoolForKey:@"usesProxy"];
    hostname = [decoder decodeObjectForKey:@"proxyHostname"];
    port = [decoder decodeObjectForKey:@"proxyPort"];
    newProxyVersion = [decoder decodeIntForKey:@"proxyVersion"];
    username = [decoder decodeObjectForKey:@"proxyUsername"];
    password = [decoder decodeObjectForKey:@"proxyPassword"];
  }

  // If this came out nil, then something isn't kosher
  if (!port)
    return nil;
    
  return [[[J3ProxySettings alloc]
          initWithHostname:hostname
                      port:[port intValue]
                   version:newProxyVersion
                  username:username
                  password:password] autorelease];
}
@end

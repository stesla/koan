//
// MUWorld.m
//
// Copyright (C) 2004 3James Software
//

#import "MUWorld.h"

#import <J3Terminal/J3TelnetConnection.h>

static const int32_t currentVersion = 2;

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
                 usesSSL:(BOOL)newUsesSSL
               usesProxy:(BOOL)newUsesProxy
           proxyHostname:(NSString *)newProxyHostname
               proxyPort:(NSNumber *)newProxyPort
            proxyVersion:(int)newProxyVersion
           proxyUsername:(NSString *)newProxyUsername
           proxyPassword:(NSString *)newProxyPassword
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
    [self setUsesProxy:newUsesProxy];
    [self setProxyHostname:newProxyHostname];
    [self setProxyPort:newProxyPort];
    [self setProxyVersion:newProxyVersion];
    [self setProxyUsername:newProxyUsername];
    [self setProxyPassword:newProxyPassword];
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
                       usesProxy:NO
                   proxyHostname:@""
                       proxyPort:[NSNumber numberWithInt:0]
                    proxyVersion:5
                   proxyUsername:@""
                   proxyPassword:@""
                         players:[NSArray array]];
}

- (void) dealloc
{
  [worldName release];
  [worldHostname release];
  [worldPort release];
  [worldURL release];
  [proxyHostname release];
  [proxyPort release];
  [proxyUsername release];
  [proxyPassword release];
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

- (BOOL) usesProxy
{
  return usesProxy;
}

- (void) setUsesProxy:(BOOL)newUsesProxy
{
  usesProxy = newUsesProxy;
}

- (NSString *) proxyHostname
{
  return proxyHostname;
}

- (void) setProxyHostname:(NSString *)newProxyHostname
{
  NSString *copy = [newProxyHostname copy];
  [proxyHostname release];
  proxyHostname = copy;
}

- (NSNumber *) proxyPort
{
  return proxyPort;
}

- (void) setProxyPort:(NSNumber *)newProxyPort
{
  NSNumber *copy = [newProxyPort copy];
  [proxyPort release];
  proxyPort = copy;
}

- (int) proxyVersion
{
  return proxyVersion;
}

- (void) setProxyVersion:(int)newProxyVersion
{
  proxyVersion = newProxyVersion;
}

- (NSString *) proxyUsername
{
  return proxyUsername;
}

- (void) setProxyUsername:(NSString *)newProxyUsername
{
  NSString *copy = [newProxyUsername copy];
  [proxyUsername release];
  proxyUsername = copy;
}

- (NSString *) proxyPassword
{
  return proxyPassword;
}

- (void) setProxyPassword:(NSString *)newProxyPassword
{
  NSString *copy = [newProxyPassword copy];
  [proxyPassword release];
  proxyPassword = copy;
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
  J3TelnetConnection * telnet;
  telnet = [[J3TelnetConnection alloc] 
    initWithHostName:[self worldHostname]
              onPort:[[self worldPort] intValue]]; //TODO: Autorelease?

  if ([self usesSSL])
    [telnet setSecurityLevel:NSStreamSocketSecurityLevelNegotiatedSSL];
  
  if ([self usesProxy])
  {
    [telnet enableProxyWithHostname:[self proxyHostname]
                             onPort:[[self proxyPort] intValue]
                            version:[self proxyVersion]
                           username:[self proxyUsername]
                           password:[self proxyPassword]];
  }
  
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
  [encoder encodeBool:[self usesProxy] forKey:@"usesProxy"];
  [encoder encodeObject:[self proxyHostname] forKey:@"proxyHostname"];
  [encoder encodeObject:[self proxyPort] forKey:@"proxyPort"];
  [encoder encodeInt:[self proxyVersion] forKey:@"proxyVersion"];
  [encoder encodeObject:[self proxyUsername] forKey:@"proxyUsername"];
  [encoder encodeObject:[self proxyPassword] forKey:@"proxyPassword"];  
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
    {
      [self setUsesSSL:[decoder decodeBoolForKey:@"usesSSL"]];
      [self setUsesProxy:[decoder decodeBoolForKey:@"usesProxy"]];
      [self setProxyHostname:[decoder decodeObjectForKey:@"proxyHostname"]];
      [self setProxyPort:[decoder decodeObjectForKey:@"proxyPort"]];
      [self setProxyVersion:[decoder decodeIntForKey:@"proxyVersion"]];
      [self setProxyUsername:[decoder decodeObjectForKey:@"proxyUsername"]];
      [self setProxyPassword:[decoder decodeObjectForKey:@"proxyPassword"]];
    }
    else
    {
      [self setUsesSSL:NO];
      [self setUsesProxy:NO];
      [self setProxyHostname:@""];
      [self setProxyPort:[NSNumber numberWithInt:0]];
      [self setProxyVersion:5];
      [self setProxyUsername:@""];
      [self setProxyPassword:@""];
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
                                                 usesSSL:[self usesSSL]
                                               usesProxy:[self usesProxy]
                                           proxyHostname:[self proxyHostname]
                                               proxyPort:[self proxyPort]
                                            proxyVersion:[self proxyVersion]
                                           proxyUsername:[self proxyUsername]
                                           proxyPassword:[self proxyPassword]
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

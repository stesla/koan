//
// MUPlayer.m
//
// Copyright (C) 2004 3James Software
//

#import "MUPlayer.h"

static const int32_t currentVersion = 1;

@implementation MUPlayer

- (id) initWithName:(NSString *)newName
           password:(NSString *)newPassword
 connectOnAppLaunch:(BOOL)newConnectOnAppLaunch
              world:(MUWorld *)newWorld
{
  if (self = [super init])
  {
    [self setName:newName];
    [self setPassword:newPassword];
    [self setConnectOnAppLaunch:newConnectOnAppLaunch];
    [self setWorld:newWorld];
  }
  return self;
}

- (id) init
{
  return [self initWithName:@"" password:@"" connectOnAppLaunch:NO world:nil];
}

- (void) dealloc
{
  [name release];
  [password release];
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
  NSString *copy = [newName copy];
  [name release];
  name = copy;
}

- (NSString *) password
{
  return password;
}

- (void) setPassword:(NSString *)newPassword
{
  NSString *copy = [newPassword copy];
  [password release];
  password = copy;
}

- (BOOL) connectOnAppLaunch
{
  return connectOnAppLaunch;
}

- (void) setConnectOnAppLaunch:(BOOL)newConnectOnAppLaunch
{
  connectOnAppLaunch = newConnectOnAppLaunch;
}

- (MUWorld *) world
{
  return world;
}

- (void) setWorld:(MUWorld *)newWorld
{
  world = newWorld;
}

#pragma mark -
#pragma mark Actions

- (NSString *) frameName
{
  return [NSString stringWithFormat:@"%@.%@.%@", [world worldHostname], [world worldPort], [self name]];
}

- (NSString *) loginString
{
  return [NSString stringWithFormat:@"connect \"%@\" %@", [self name], [self password]];
}

- (NSString *) windowName
{
  return [NSString stringWithFormat:@"%@ @ %@", [self name], [world worldName]];
}

#pragma mark -
#pragma mark NSCoding protocol

- (void) encodeWithCoder:(NSCoder *)encoder
{
  [encoder encodeInt32:currentVersion forKey:@"version"];
  
  [encoder encodeObject:[self name] forKey:@"name"];
  [encoder encodeObject:[self password] forKey:@"password"];
  
  [encoder encodeBool:[self connectOnAppLaunch] forKey:@"connectOnAppLaunch"];
}

- (id) initWithCoder:(NSCoder *)decoder
{
  if (self = [super init])
  {
    int32_t version = [decoder decodeInt32ForKey:@"version"];
    
    [self setName:[decoder decodeObjectForKey:@"name"]];
    [self setPassword:[decoder decodeObjectForKey:@"password"]];
    
    if (version >= 1)
    {
      [self setConnectOnAppLaunch:[decoder decodeBoolForKey:@"connectOnAppLaunch"]];
    }
    else
    {
      [self setConnectOnAppLaunch:NO];
    }
  }
  return self;
}

#pragma mark -
#pragma mark NSCopying protocol

- (id) copyWithZone:(NSZone *)zone
{
  return [[MUPlayer allocWithZone:zone] initWithName:[self name]
                                            password:[self password]
                                  connectOnAppLaunch:[self connectOnAppLaunch]
                                               world:[self world]];
}

@end

//
// MUPlayer.m
//
// Copyright (C) 2004 3James Software
//

#import "MUPlayer.h"

static const int32_t currentVersion = 0;

@implementation MUPlayer

- (id) initWithName:(NSString *)newName password:(NSString *)newPassword world:(MUWorld *)newWorld
{
  if (self = [super init])
  {
    [self setName:newName];
    [self setPassword:newPassword];
    [self setWorld:newWorld];
  }
  return self;
}

- (id) init
{
  return [self initWithName:NSLocalizedString (MULUnnamedPlayer, nil) password:@"" world:nil];
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

- (NSString *) loginString
{
  return [NSString stringWithFormat:@"connect %@ %@", [self name], [self password]];
}

#pragma mark -
#pragma mark NSCoding protocol

- (void) encodeWithCoder:(NSCoder *)encoder
{
  [encoder encodeInt32:currentVersion forKey:@"version"];
  
  [encoder encodeObject:[self name] forKey:@"name"];
  [encoder encodeObject:[self password] forKey:@"password"];
}

- (id) initWithCoder:(NSCoder *)decoder
{
  if (self = [super init])
  {
    int32_t version = [decoder decodeInt32ForKey:@"version"];
    
    [self setName:[decoder decodeObjectForKey:@"name"]];
    [self setPassword:[decoder decodeObjectForKey:@"password"]];
  }
  return self;
}

#pragma mark -
#pragma mark NSCopying protocol

- (id) copyWithZone:(NSZone *)zone
{
  return [[MUPlayer allocWithZone:zone] initWithName:[self name]
                                            password:[self password]
                                               world:[self world]];
}

@end

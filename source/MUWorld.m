//
// MUWorld.m
//
// Copyright (C) 2004 3James Software
//

#import "MUWorld.h"

@implementation MUWorld

- (void) initialize
{
  [MUWorld setKeys:[NSArray arrayWithObjects:@"name", @"hostname", @"port", nil]
    triggerChangeNotificationsForDependentKey:@"descript"];
}

+ (id) connectionWithDictionary:(NSDictionary *)dictionary
{
  return [[[MUWorld alloc] initWithDictionary:dictionary] autorelease];
}

- (id) initWithName:(NSString *)newName
           hostname:(NSString *)newHostname
               port:(NSNumber *)newPort
{
  if (self = [super init])
  {
    [self setName:[newName copy]];
    [self setHostname:[newHostname copy]];
    [self setPort:newPort];
  }
  return self;
}

- (id) initWithDictionary:(NSDictionary *)dictionary
{
  return [self initWithName:[dictionary objectForKey:@"name"]
                   hostname:[dictionary objectForKey:@"hostname"]
                       port:[dictionary objectForKey:@"port"]];
}

- (NSDictionary *) objectDictionary
{
  NSArray *keys = [NSArray arrayWithObjects:@"name", @"hostname", @"port", nil];
  NSArray *objects = [NSArray arrayWithObjects:[self name], [self hostname], [self port], nil];
  
  return [NSDictionary dictionaryWithObjects:objects forKeys:keys];
}

- (id) init
{
  return [self initWithName:NSLocalizedString (MULUntitledWorld, nil)
                   hostname:@"" port:[NSNumber numberWithInt:0]];
}

- (NSString *) descript
{
  return [NSString stringWithFormat:@"%@ (%@ %@)", [self name], [self hostname], [self port]];
}

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

- (NSString *) hostname
{
  return hostname;
}

- (void) setHostname:(NSString *)newHostname
{
  NSString *copy = [newHostname copy];
  [hostname release];
  hostname = copy;
}

- (NSNumber *) port
{
  return port;
}

- (void) setPort:(NSNumber *)newPort
{
  NSNumber *copy = [newPort copy];
  [port release];
  port = copy;
}


- (NSDictionary *) players
{
  return players;
}

- (void) setPlayers:(NSDictionary *)newPlayers
{
  NSDictionary *copy = [newPlayers copy];
  [players release];
  players = copy;
}

// Implementation of the NSCopying protocol.

- (id) copyWithZone:(NSZone *)zone
{
  return [[MUWorld allocWithZone:zone] initWithName:name
                                                    hostname:hostname
                                                        port:port];
}

@end

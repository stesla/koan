//
// MUConnectionSpec.m
//
// Copyright (C) 2004 3James Software
//

#import "MUConnectionSpec.h"

@implementation MUConnectionSpec

+ (id) connectionWithDictionary:(NSDictionary *)dictionary
{
  return [[[MUConnectionSpec alloc] initWithDictionary:dictionary] autorelease];
}

- (id) initWithName:(NSString *)newName
           hostname:(NSString *)newHostname
               port:(NSNumber *)newPort
           username:(NSString *)newUsername
           password:(NSString *)newPassword
{
  if (self = [super init])
  {
    [self setName:[newName copy]];
    [self setHostname:[newHostname copy]];
    [self setPort:newPort];
    [self setUsername:[newUsername copy]];
    [self setPassword:[newPassword copy]];
  }
  return self;
}

- (id) initWithDictionary:(NSDictionary *)dictionary
{
  return [self initWithName:[dictionary objectForKey:@"name"]
                   hostname:[dictionary objectForKey:@"hostname"]
                       port:[dictionary objectForKey:@"port"]
                   username:[dictionary objectForKey:@"username"]
                   password:[dictionary objectForKey:@"password"]];
}

- (id) init
{
  return [self initWithName:NSLocalizedString (MULUntitledConnection, nil)
                   hostname:@"" port:[NSNumber numberWithInt:0] username:@"" password:@""];
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

- (NSString *) username
{
  return username;
}

- (void) setUsername:(NSString *)newUsername
{
  NSString *copy = [newUsername copy];
  [username release];
  username = copy;
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

- (NSDictionary *) objectDictionary
{
  NSArray *keys = [NSArray arrayWithObjects:@"name", @"hostname", @"port", @"username", @"password", nil];
  NSArray *objects = [NSArray arrayWithObjects:[self name], [self hostname], [self port], [self username], [self password], nil];
    
  return [NSDictionary dictionaryWithObjects:objects
                                     forKeys:keys];
}

// Implementation of the NSCopying protocol.

- (id) copyWithZone:(NSZone *)zone
{
  return [[MUConnectionSpec allocWithZone:zone] initWithName:name
                                                    hostname:hostname
                                                        port:port
                                                    username:username
                                                    password:password];
}

@end

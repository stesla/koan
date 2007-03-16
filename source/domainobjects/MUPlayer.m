//
// MUPlayer.m
//
// Copyright (c) 2004, 2005 3James Software
//

#import "MUPlayer.h"
#import "MUCodingService.h"

@implementation MUPlayer

- (id) initWithName:(NSString *)newName
           password:(NSString *)newPassword
              world:(MUWorld *)newWorld
{
  if (![super init])
    return nil;
  
  [self setName:newName];
  [self setPassword:newPassword];
  [self setWorld:newWorld];
  
  return self;
}

- (id) init
{
  return [self initWithName:@"" password:@"" world:nil];
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
  if (name == newName)
    return;
  [name release];
  name = [newName copy];
}

- (NSString *) password
{
  return password;
}

- (void) setPassword:(NSString *)newPassword
{
  if (password == newPassword)
    return;
  [password release];
  password = [newPassword copy];
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
  NSString *format;
  NSRange whitespaceRange = [[self name] rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
  
  if (whitespaceRange.location == NSNotFound)
    format = @"connect %@ %@";
  else
    format = @"connect \"%@\" %@";
  
  return [NSString stringWithFormat:format, [self name], [self password]];
}

- (NSString *) uniqueIdentifier
{
  return [NSString stringWithFormat:@"%@.%@.%@", [world hostname], [world port], [self name]];
}

- (NSString *) windowTitle
{
  return [NSString stringWithFormat:@"%@ @ %@", [self name], [world name]];
}

#pragma mark -
#pragma mark NSCoding protocol

- (void) encodeWithCoder:(NSCoder *)encoder
{
  [MUCodingService encodePlayer:self withCoder:encoder];
}

- (id) initWithCoder:(NSCoder *)decoder
{
  if (![super init])
    return nil;
  
  [MUCodingService decodePlayer:self withCoder:decoder];
  
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

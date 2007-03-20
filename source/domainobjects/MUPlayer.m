//
// MUPlayer.m
//
// Copyright (c) 2004, 2005, 2007 3James Software
//

#import "MUPlayer.h"
#import "MUCodingService.h"

@implementation MUPlayer

+ (MUPlayer *) playerWithName:(NSString *)newName
  									 password:(NSString *)newPassword
  											world:(MUWorld *)newWorld
{
  return [[[self alloc] initWithName:newName password:newPassword world:newWorld] autorelease];
}

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
  if (![self name])
  	return nil;

  NSRange whitespaceRange = [[self name] rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
  
  if ([self password] && [[self password] length] > 0)
  {
  	if (whitespaceRange.location == NSNotFound)
  		return [NSString stringWithFormat:@"connect %@ %@", [self name], [self password]];
  	else
  		return [NSString stringWithFormat:@"connect \"%@\" %@", [self name], [self password]];
  }
  else
  {
  	if (whitespaceRange.location == NSNotFound)
  		return [NSString stringWithFormat:@"connect %@", [self name]];
  	else
  		return [NSString stringWithFormat:@"connect \"%@\"", [self name]];
  }
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

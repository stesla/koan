//
// MUWorldRegistry.m
//
// Copyright (C) 2004 3James Software
//

#import "MUWorldRegistry.h"
#import "MUPlayer.h"
#import "MUWorld.h"

static NSString *defaultWorldsKey = @"MUPWorlds";
static MUWorldRegistry *sharedRegistry = nil;

@interface MUWorldRegistry (Private)

- (void) postWorldsUpdatedNotification;
- (void) readWorldsFromUserDefaults;
- (void) writeWorldsToUserDefaults;

@end

#pragma mark -

@implementation MUWorldRegistry

+ (id) sharedRegistry
{
  if (!sharedRegistry)
  {
    sharedRegistry = [[MUWorldRegistry alloc] createSharedRegistryWithDefaultsKey:defaultWorldsKey];
  }
  
  return sharedRegistry;
}

- (id) createSharedRegistryWithDefaultsKey:(NSString *)key
{
  if (sharedRegistry)
  {
    [self autorelease];
    return sharedRegistry;
  }
  if (self = [super init])
  {
    [self setWorldsKey:key];
    [self readWorldsFromUserDefaults];
    sharedRegistry = self;
  }
  return self;
}

- (id) init
{
  [self autorelease];
  return [MUWorldRegistry sharedRegistry];
}

- (void) dealloc
{
  [worlds release];
  [worldsKey release];
}

#pragma mark -
#pragma mark Accessors

- (NSArray *) worlds
{
  return worlds;
}

- (void) setWorlds:(NSArray *)newWorlds
{
  NSArray *copy = [newWorlds copy];
  [worlds release];
  worlds = copy;
}

- (NSString *) worldsKey
{
  return worldsKey;
}

- (void) setWorldsKey:(NSString *)newWorldsKey
{
  NSString *copy = [newWorldsKey copy];
  [worldsKey release];
  worldsKey = copy;
  [self postWorldsUpdatedNotification];
}

#pragma mark -
#pragma mark Actions

- (unsigned) count
{
  return [worlds count];
}

- (void) saveWorlds
{
  [self writeWorldsToUserDefaults];
}

- (MUWorld *) worldAtIndex:(unsigned)index
{
  return [worlds objectAtIndex:index];
}

@end

#pragma mark -

@implementation MUWorldRegistry (Private)

- (void) postWorldsUpdatedNotification
{
  [[NSNotificationCenter defaultCenter] postNotificationName:MUWorldsUpdatedNotification
                                                      object:self];
}

- (void) readWorldsFromUserDefaults
{
  NSData *worldsData = [[NSUserDefaults standardUserDefaults] dataForKey:MUPWorlds];
  
  if (worldsData)
  {
    int i, worldsCount;
    
    [self setWorlds:[NSKeyedUnarchiver unarchiveObjectWithData:worldsData]];
    
    worldsCount = [worlds count];
    
    for (i = 0; i < worldsCount; i++)
    {
      MUWorld *world = [worlds objectAtIndex:i];
      NSArray *players = [world players];
      int j, playersCount = [players count];
      
      for (j = 0; j < playersCount; j++)
      {
        [[players objectAtIndex:j] setWorld:world];
      }
    }
  }
  else
  {
    [self setWorlds:[NSArray array]];
  }  
}

- (void) writeWorldsToUserDefaults
{
  [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:worlds] forKey:worldsKey];
}

@end

//
// MUWorldRegistry.m
//
// Copyright (C) 2004 3James Software
//

#import "MUProfileRegistry.h"
#import "MUWorldRegistry.h"
#import "MUProfile.h"

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

- (NSMutableArray *) worlds
{
  return worlds;
}

- (void) setWorlds:(NSArray *)newWorlds
{
  NSSortDescriptor *sortDesc = [[[NSSortDescriptor alloc] initWithKey:@"worldName" ascending:YES] autorelease];
  NSMutableArray *copy = [[newWorlds sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDesc]] mutableCopy];
  
  [worlds release];
  worlds = copy;
  [self postWorldsUpdatedNotification];
}

- (void) insertObject:(MUWorld *)world inWorldsAtIndex:(unsigned)index
{
  NSSortDescriptor *sortDesc = [[[NSSortDescriptor alloc] initWithKey:@"worldName" ascending:YES] autorelease];
  
  [worlds insertObject:world atIndex:index];
  [worlds sortUsingDescriptors:[NSArray arrayWithObject:sortDesc]];
  [self postWorldsUpdatedNotification];
}

- (void) removeObjectFromWorldsAtIndex:(unsigned)index
{
  [worlds removeObjectAtIndex:index];
  [self postWorldsUpdatedNotification];
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
    MUProfileRegistry *profiles = [MUProfileRegistry sharedRegistry];
    int i, worldsCount;
    
    [self setWorlds:[NSKeyedUnarchiver unarchiveObjectWithData:worldsData]];
    
    worldsCount = [worlds count];
    
    for (i = 0; i < worldsCount; i++)
    {
      MUWorld *world = [worlds objectAtIndex:i];
      MUPlayer *player = nil;
      MUProfile *profile = nil;
      NSArray *players = [world players];
      int j, playersCount = [players count];
    
      profile = [profiles profileForWorld:world];
      for (j = 0; j < playersCount; j++)
      {
        player = [players objectAtIndex:i];
        [player setWorld:world];
        profile = [profiles profileForWorld:world player:player];
        [profile setWorld:world];
        [profile setPlayer:player];
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

//
// MUWorldRegistry.m
//
// Copyright (C) 2004, 2005 3James Software
//

#import "MUServices.h"
#import "MUProfile.h"

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
    sharedRegistry = [[MUWorldRegistry alloc] init];
    [sharedRegistry readWorldsFromUserDefaults];
  }
  return sharedRegistry;
}

- (id) init
{
  self = [super init];
  if (self)
  {
    [self setWorlds:[NSArray array]];
  }
  return self;
}

- (void) dealloc
{
  [worlds release];
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
    MUProfileRegistry *profiles = [MUServices profileRegistry];
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
        player = [players objectAtIndex:j];
        [player setWorld:world];
        profile = [profiles profileForWorld:world player:player];
        [profile setWorld:world];
        [profile setPlayer:player];
      }
    }
  }
}

- (void) writeWorldsToUserDefaults
{
  NSData *data = [NSKeyedArchiver archivedDataWithRootObject:worlds];
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject:data forKey:MUPWorlds];
}

@end

//
// MUWorldRegistry.m
//
// Copyright (c) 2007 3James Software. All rights reserved.
//

#import "MUServices.h"
#import "MUProfile.h"

static MUWorldRegistry *defaultRegistry = nil;

@interface MUWorldRegistry (Private)

- (void) cleanUpDefaultRegistry: (NSNotification *) notification;
- (void) postWorldsDidChangeNotification;
- (void) readWorldsFromUserDefaults;
- (void) writeWorldsToUserDefaults;

@end

#pragma mark -

@implementation MUWorldRegistry

+ (MUWorldRegistry *) defaultRegistry
{
  if (!defaultRegistry)
  {
    defaultRegistry = [[MUWorldRegistry alloc] init];
    [defaultRegistry readWorldsFromUserDefaults];
    
    [[NSNotificationCenter defaultCenter] addObserver: defaultRegistry
                                             selector: @selector (cleanUpDefaultRegistry:)
                                                 name: NSApplicationWillTerminateNotification
                                               object: NSApp];
  }
  return defaultRegistry;
}

- (id) init
{
  if (![super init])
    return nil;
  
  [self setWorlds: [NSArray array]];
  
  return self;
}

- (void) dealloc
{
  [worlds release];
  [super dealloc];
}

#pragma mark -
#pragma mark Key-value coding accessors

- (NSMutableArray *) worlds
{
  return worlds;
}

- (void) setWorlds: (NSArray *) newWorlds
{
  if (worlds == newWorlds)
    return;
  
  [worlds release];
  worlds = [newWorlds mutableCopy];
  [self postWorldsDidChangeNotification];
}

- (void) insertObject: (MUWorld *) world inWorldsAtIndex: (unsigned) worldIndex
{
  [worlds insertObject: world atIndex: worldIndex];
  [self postWorldsDidChangeNotification];
}

- (void) removeObjectFromWorldsAtIndex: (unsigned) worldIndex
{
  [worlds removeObjectAtIndex: worldIndex];
  [self postWorldsDidChangeNotification];
}

#pragma mark -
#pragma mark Actions

- (unsigned) count
{
  return [worlds count];
}

- (int) indexOfWorld: (MUWorld *) world
{
  for (unsigned i = 0; i < [worlds count]; i++)
  {
  	if (world == [worlds objectAtIndex: i])
  	{
  		return (int) i;
  	}
  }
  
  return -1;
}

- (void) removeWorld: (MUWorld *) world
{
  [worlds removeObject: world];
  [self postWorldsDidChangeNotification];
}

- (void) replaceWorld: (MUWorld *) oldWorld withWorld: (MUWorld *) newWorld
{
  for (unsigned i = 0; i < [worlds count]; i++)
  {
  	if (oldWorld == [worlds objectAtIndex: i])
  	{
  		[worlds replaceObjectAtIndex: i withObject: newWorld];
  		[self postWorldsDidChangeNotification];
  		break;
  	}
  }
}

- (void) saveWorlds
{
  [self writeWorldsToUserDefaults];
}

- (MUWorld *) worldAtIndex: (unsigned) worldIndex
{
  return [worlds objectAtIndex: worldIndex];
}

- (MUWorld *) worldForUniqueIdentifier: (NSString *) identifier
{
  for (unsigned i = 0; i < [worlds count]; i++)
  {
  	MUWorld *world = [worlds objectAtIndex: i];
  	
  	if ([identifier isEqualToString: [world uniqueIdentifier]])
  		return world;
  }
  
  return nil;
}

@end

#pragma mark -

@implementation MUWorldRegistry (Private)

- (void) cleanUpDefaultRegistry: (NSNotification *) notification
{
  [[NSNotificationCenter defaultCenter] removeObserver: defaultRegistry];
  [defaultRegistry release];
}

- (void) postWorldsDidChangeNotification
{
  [[NSNotificationCenter defaultCenter] postNotificationName: MUWorldsDidChangeNotification
                                                      object: self];
}

- (void) readWorldsFromUserDefaults
{
  NSData *worldsData = [[NSUserDefaults standardUserDefaults] dataForKey: MUPWorlds];
  
  if (!worldsData)
    return;
  
  [self setWorlds: [NSKeyedUnarchiver unarchiveObjectWithData: worldsData]];
  
  for (unsigned i = 0; i < [worlds count]; i++)
  {
    MUWorld *world = [worlds objectAtIndex: i];
    
    for (unsigned j = 0; j < [[world players] count]; j++)
    {
      MUPlayer *player = [[world players] objectAtIndex: j];
      [player setWorld: world];
      
      MUProfile *profile = [[MUServices profileRegistry] profileForWorld: world player: player];
      [profile setWorld: world];
      [profile setPlayer: player];
    }
  }
}

- (void) writeWorldsToUserDefaults
{
  NSData *data = [NSKeyedArchiver archivedDataWithRootObject: worlds];
  
  [[NSUserDefaults standardUserDefaults] setObject: data forKey: MUPWorlds];
}

@end

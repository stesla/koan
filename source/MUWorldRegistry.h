//
// MUWorldRegistry.h
//
// Copyright (C) 2004 3James Software
//

#import <Cocoa/Cocoa.h>

@class MUWorld;

// MUWorldRegistry is a Singleton.

@interface MUWorldRegistry : NSObject
{
  NSMutableArray *worlds;
  NSString *worldsKey;
}

+ (id) sharedRegistry;

// Default sort-of-initializer.
- (id) createSharedRegistryWithDefaultsKey:(NSString *)key;

- (NSMutableArray *) worlds;
- (void) setWorlds:(NSArray *)newWorlds;
- (void) insertObject:(MUWorld *)world inWorldsAtIndex:(unsigned)index;
- (void) removeObjectFromWorldsAtIndex:(unsigned)index;

- (NSString *) worldsKey;
- (void) setWorldsKey:(NSString *)newWorldsKey;

- (unsigned) count;
- (void) saveWorlds;
- (MUWorld *) worldAtIndex:(unsigned)index;

@end

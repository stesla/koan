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
  NSArray *worlds;
  NSString *worldsKey;
}

+ (id) sharedRegistry;

// Default sort-of-initializer.
- (id) createSharedRegistryWithDefaultsKey:(NSString *)key;

- (NSArray *) worlds;
- (void) setWorlds:(NSArray *)newWorlds;
- (NSString *) worldsKey;
- (void) setWorldsKey:(NSString *)newWorldsKey;

- (unsigned) count;
- (void) saveWorlds;
- (MUWorld *) worldAtIndex:(unsigned)index;

@end

//
// MUWorldRegistry.h
//
// Copyright (C) 2004 3James Software
//

#import <Cocoa/Cocoa.h>

@class MUWorld;
@class MUPlayer;

// MUWorldRegistry is a Singleton.

@interface MUWorldRegistry : NSObject
{
  NSMutableArray *worlds;
}

// This is how you should get an MUWorldRegistry instance
+ (id) sharedRegistry;

- (NSMutableArray *) worlds;
- (void) setWorlds:(NSArray *)newWorlds;
- (void) insertObject:(MUWorld *)world inWorldsAtIndex:(unsigned)index;
- (void) removeObjectFromWorldsAtIndex:(unsigned)index;

- (unsigned) count;
- (void) saveWorlds;
- (MUWorld *) worldAtIndex:(unsigned)index;
@end

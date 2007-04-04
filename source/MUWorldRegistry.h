//
// MUWorldRegistry.h
//
// Copyright (c) 2007 3James Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MUWorld;
@class MUPlayer;

@interface MUWorldRegistry : NSObject
{
  NSMutableArray *worlds;
}

+ (MUWorldRegistry *) defaultRegistry;

- (NSMutableArray *) worlds;
- (void) setWorlds: (NSArray *) newWorlds;
- (void) insertObject: (MUWorld *) world inWorldsAtIndex: (unsigned) worldIndex;
- (void) removeObjectFromWorldsAtIndex: (unsigned) worldIndex;

- (unsigned) count;
- (int) indexOfWorld: (MUWorld *) world;
- (void) removeWorld: (MUWorld *) world;
- (void) replaceWorld: (MUWorld *) oldWorld withWorld: (MUWorld *) newWorld;
- (void) saveWorlds;
- (MUWorld *) worldAtIndex: (unsigned) worldIndex;
- (MUWorld *) worldForUniqueIdentifier: (NSString *) identifier;

@end

//
// MUWorldRegistry.h
//
// Copyright (c) 2010 3James Software.
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
- (MUWorld *) worldAtIndex: (unsigned) worldIndex;
- (MUWorld *) worldForUniqueIdentifier: (NSString *) identifier;

@end

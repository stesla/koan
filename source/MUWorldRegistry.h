//
// MUWorldRegistry.h
//
// Copyright (c) 2004, 2005 3James Software
//

#import <Cocoa/Cocoa.h>

@class MUWorld;
@class MUPlayer;

@interface MUWorldRegistry : NSObject
{
  NSMutableArray *worlds;
}

+ (MUWorldRegistry *) sharedRegistry;

- (NSMutableArray *) worlds;
- (void) setWorlds:(NSArray *)newWorlds;
- (void) insertObject:(MUWorld *)world inWorldsAtIndex:(unsigned)index;
- (void) removeObjectFromWorldsAtIndex:(unsigned)index;

- (unsigned) count;
- (void) saveWorlds;
- (MUWorld *) worldAtIndex:(unsigned)index;
@end

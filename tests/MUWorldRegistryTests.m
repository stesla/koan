//
//  MUWorldRegistryTests.m
//  Koan
//
//  Created by Samuel on 1/6/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "MUWorldRegistryTests.h"
#import "MUWorldRegistry.h"
#import "MUProfile.h"

@implementation MUWorldRegistryTests

- (void) setUp
{
  registry = [[MUWorldRegistry alloc] init];
  world = [[MUWorld alloc] init];
}

- (void) tearDown
{
  [world release];
  [registry release];
}

- (void) testAddWorld
{
  [registry addWorld:world];
  [self assert:[registry worldAtIndex:0]
        equals:world];
}

- (void) testContainsWorld
{
  [self assertFalse:[registry containsWorld:world]
            message:@"Before add"];
  [registry addWorld:world];
  [self assertTrue:[registry containsWorld:world]
           message:@"After add"];
}

- (void) testNoDuplicateWorlds
{
  [registry addWorld:world];
  [registry addWorld:world];
  [self assertInt:[registry count] equals:1];
}

- (void) testRemoveWorld
{
  [registry addWorld:world];
  [registry removeWorld:world];
  [self assertInt:[registry count] equals:0];
}

- (void) testAddPlayer
{
  MUPlayer *player = [[[MUPlayer alloc] init] autorelease];
  
  [registry addWorld:world];
  [registry addPlayer:player toWorld:world];
  [self assert:[player world] equals:world];
  [self assert:[[world players] objectAtIndex:0]
        equals:player];
}
@end

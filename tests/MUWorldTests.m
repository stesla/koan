//
//  MUWorldTests.m
//  Koan
//
//  Created by Samuel on 1/2/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "MUWorldTests.h"
#import "MUWorld.h"
#import "MUPlayer.h"

@implementation MUWorldTests

- (void) setUp
{
  world = [[MUWorld alloc] init];
  player = [[MUPlayer alloc] init];
}

- (void) tearDown
{
  [player release];
  [world release];
}

- (void) testUniqueIdentifier
{
  [world setWorldName:@"Test World"];
  [self assert:[world uniqueIdentifier] equals:@"test.world"]; 
}

- (void) testAddPlayer
{
  [world addPlayer:player];
  [self assert:[[world players] objectAtIndex:0]
        equals:player];
  [self assert:[player world]
        equals:world];
}

- (void) testContainsPlayer
{
  [world addPlayer:player];
  [self assertTrue:[world containsPlayer:player]];
}

- (void) testNoDuplicatePlayers
{
  [world addPlayer:player];
  [world addPlayer:player];
  [self assertInt:[[world players] count] equals:1];
}

- (void) testRemovePlayer
{
  [world addPlayer:player];
  [world removePlayer:player];
  [self assertFalse:[world containsPlayer:player]];
}

@end

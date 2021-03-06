//
// MUWorldTests.m
//
// Copyright (c) 2010 3James Software.
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
  world.name = @"Test World";
  [self assert: world.uniqueIdentifier equals: @"test.world"];
}

- (void) testAddPlayer
{
  [world addPlayer: player];
  [self assert: [[world players] objectAtIndex: 0]
        equals: player];
  [self assert: player.world
        equals: world];
}

- (void) testContainsPlayer
{
  [world addPlayer: player];
  [self assertTrue: [world containsPlayer: player]];
}

- (void) testNoDuplicatePlayers
{
  [world addPlayer: player];
  [world addPlayer: player];
  [self assertInt: [[world players] count] equals: 1];
}

- (void) testRemovePlayer
{
  [world addPlayer: player];
  [world removePlayer: player];
  [self assertFalse: [world containsPlayer: player]];
  [self assertNil: player.world];
}

- (void) testReplacePlayer
{
  MUPlayer *otherPlayer = [[MUPlayer alloc] init];
  @try
  {
    [world addPlayer: player];
    [self assertTrue: [world containsPlayer: player]];
    [self assert: player.world
          equals: world];
    
    [world replacePlayer: player withPlayer: otherPlayer];
    
    [self assertFalse: [world containsPlayer: player]];
    [self assertNil: player.world];
    [self assertTrue: [world containsPlayer: otherPlayer]];
    [self assert: otherPlayer.world
          equals: world];
  }
  @finally
  {
    [otherPlayer release];
  }
}

- (void) testNilPlayers
{
  MUWorld *thisWorld = [[MUWorld alloc] initWithName: @"" hostname: @"" port: 0 URL: @"" players: nil];
  @try
  {
    [thisWorld addPlayer: player];
    [self assertInt: [[thisWorld players] count] equals: 1];
  }
  @finally
  {
    [thisWorld release];
  }
}

@end

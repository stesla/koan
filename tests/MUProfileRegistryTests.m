//
// MUProfileRegistryTest.m
//
// Copyright (c) 2005 3James Software
//

#import "MUProfileRegistryTests.h"
#import "MUProfileRegistry.h"
#import "MUProfile.h"
#import "MUServices.h"
#import "MUWorld.h"

@interface MUProfileRegistryTests (Private)
- (void) assertProfile:(MUProfile *)profile
                 world:(MUWorld *)world 
                player:(MUPlayer *)player;

- (MUWorld *) testWorld;
- (MUPlayer *) testPlayerWithWorld:(MUWorld *)world;
@end

@implementation MUProfileRegistryTests

- (void) setUp
{
  registry = [[MUProfileRegistry alloc] init];
}

- (void) tearDown
{
  [registry release];
}

- (void) testSharedRegistry
{
  MUProfileRegistry *registryOne, *registryTwo;
  
  registryOne = [MUServices profileRegistry];
  [self assertNotNil:registryOne];
  
  registryTwo = [MUServices profileRegistry];
  [self assert:registryOne equals:registryTwo];
}

- (void) testProfileWithWorld
{
  MUProfile *profileOne = nil, *profileTwo = nil;
  MUWorld *world = [self testWorld];
  
  profileOne = [registry profileForWorld:world];
  [self assertProfile:profileOne world:world player:nil];
  profileTwo = [registry profileForUniqueIdentifier:@"test.world"];
  [self assert:profileTwo equals:profileOne message:@"First"];
  profileOne = [registry profileForWorld:world];
  [self assert:profileOne equals:profileTwo message:@"Second"];
}

- (void) testProfileWithWorldAndPlayer
{
  MUProfile *profileOne = nil, *profileTwo = nil;
  MUWorld *world = [self testWorld];
  MUPlayer *player = [self testPlayerWithWorld:world];
  
  profileOne = [registry profileForWorld:world player:player];
  [self assertProfile:profileOne world:world player:player];
  profileTwo = [registry profileForUniqueIdentifier:@"test.world.user"];
  [self assert:profileTwo equals:profileOne message:@"First"];
  profileOne = [registry profileForWorld:world player:player];
  [self assert:profileOne equals:profileTwo message:@"Second"];
}

- (void) testContains
{
  MUWorld *world = [self testWorld];
  MUPlayer *player = [self testPlayerWithWorld:world];
  
  [self assertFalse:[registry containsProfileForWorld:world player:player]
            message:@"Before adding"];
  
  [registry profileForWorld:world player:player];
  
  [self assertTrue:[registry containsProfileForWorld:world player:player]
           message:@"After adding"];
}

- (void) testRemove
{
  MUWorld *world = [self testWorld];
  MUPlayer *player = [self testPlayerWithWorld:world];

  [registry profileForWorld:world player:player];
  [self assertTrue:[registry containsProfileForWorld:world player:player]
           message:@"Before removing"];  
  
  [registry removeProfileForWorld:world player:player];  
  [self assertFalse:[registry containsProfileForWorld:world player:player]
            message:@"After removing"];

}

- (void) testRemoveWorld
{
  MUWorld *world = [self testWorld];
  MUPlayer *player = [self testPlayerWithWorld:world];
  [world addPlayer:player];
  
  [registry profileForWorld:world];
  [registry profileForWorld:world player:player];
  [registry removeAllProfilesForWorld:world];
  [self assertFalse:[registry containsProfileForWorld:world]
            message:@"World only"];
  [self assertFalse:[registry containsProfileForWorld:world
                                               player:player]
            message:@"World and player"];
}
@end

@implementation MUProfileRegistryTests (Private)
- (void) assertProfile:(MUProfile *)profile
                 world:(MUWorld *)world 
                player:(MUPlayer *)player
{
  [self assertNotNil:profile];
  [self assert:[profile world] equals:world];
  [self assert:[profile player] equals:player];
}

- (MUWorld *) testWorld
{
  MUWorld * world = [[[MUWorld alloc] init] autorelease];
  [world setWorldName:@"Test World"];
  return world;
}

- (MUPlayer *) testPlayerWithWorld:(MUWorld *)world
{
  return [[[MUPlayer alloc] initWithName:@"User"
                                password:@""
                                   world:world] autorelease];
}
@end

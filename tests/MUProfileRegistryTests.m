//
//  MUProfileRegistryTest.m
//  Koan
//
//  Created by Samuel on 1/1/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "MUProfileRegistryTests.h"
#import "MUProfileRegistry.h"
#import "MUProfile.h"
#import "MUWorld.h"

@implementation MUProfileRegistryTests

- (void) testSharedRegistry
{
  MUProfileRegistry *registryOne, *registryTwo;
  
  registryOne = [MUProfileRegistry sharedRegistry];
  [self assertNotNil:registryOne];
  
  registryTwo = [MUProfileRegistry sharedRegistry];
  [self assert:registryOne equals:registryTwo];
}

- (void) testProfileRetrieval
{
  MUProfile *profileOne = nil, *profileTwo = nil, *profileThree = nil;
  MUWorld *world = nil;
  MUPlayer *player = nil;
  MUProfileRegistry *registry = [[MUProfileRegistry alloc] init];
  
  world = [[[MUWorld alloc] init] autorelease];
  [world setWorldName:@"Test World"];
  
  profileOne = [registry profileForWorld:world];
  [self assertNotNil:profileOne];
  [self assert:[profileOne world] equals:world];
  [self assertNil:[profileOne player]];
  
  profileTwo = [registry profileForUniqueIdentifier:@"test.world"];
  [self assertNotNil:profileTwo];
  [self assert:profileTwo equals:profileOne];
  
  player = [[[MUPlayer alloc] initWithName:@"User"
                                  password:@""
                        connectOnAppLaunch:NO
                                     world:world] autorelease];
  
  profileThree = [registry profileForWorld:world player:player];
  [self assertNotNil:profileThree];
  [self assert:[profileThree world] equals:world];
  [self assert:[profileThree player] equals:player];
  [self assertFalse:(profileThree == profileOne) message:@"New profile"];

  profileTwo = [registry profileForUniqueIdentifier:@"test.world.user"];
  [self assertNotNil:profileTwo];
  [self assert:profileTwo equals:profileThree];
}
@end

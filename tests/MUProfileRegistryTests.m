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

- (void) testProfileWithWorld
{
  MUProfile *profileOne = nil, *profileTwo = nil;
  MUWorld *world = nil;
  MUProfileRegistry *registry = [[MUProfileRegistry alloc] init];
  
  world = [[MUWorld alloc]
    initWithWorldName:@"Test World"
        worldHostname:@"test.example.com"
            worldPort:[NSNumber numberWithInt:5678]
             worldURL:@""
   connectOnAppLaunch:NO
              usesSSL:NO
        proxySettings:nil
              players:[NSArray array]];
  
  profileOne = [registry profileForWorld:world];
  [self assertNotNil:profileOne];
  [self assert:[profileOne world] equals:world];
  
  profileTwo = [registry profileForUniqueIdentifier:@"Test World"];
  [self assertNotNil:profileTwo];
  [self assert:profileTwo equals:profileOne];
}
@end

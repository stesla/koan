//
//  MUProfileTests.m
//  Koan
//
//  Created by Samuel on 1/3/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "MUProfileTests.h"
#import "MUProfile.h"


@implementation MUProfileTests

- (void) testUniqueIdentifer
{
  MUWorld *world = nil;
  MUPlayer *player = nil;
  MUProfile *profile = nil;
  
  world = [[[MUWorld alloc] init] autorelease];
  [world setWorldName:@"Test World"];
  
  profile = [MUProfile profileWithWorld:world];
  [self assert:[profile uniqueIdentifier] equals:@"test.world"];
  
  player = [[[MUPlayer alloc] initWithName:@"User"
                                  password:@""
                        connectOnAppLaunch:NO
                                     world:world] autorelease];
  
  profile = [MUProfile profileWithWorld:world player:player];
  [self assert:[profile uniqueIdentifier] equals:@"test.world.user"];
}

@end

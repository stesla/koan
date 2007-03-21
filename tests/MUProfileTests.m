//
// MUProfileTests.m
//
// Copyright (c) 2005, 2006, 2007 3James Software
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
  [world setName: @"Test World"];
  
  profile = [MUProfile profileWithWorld: world];
  [self assert: [profile uniqueIdentifier] equals: @"test.world"];
  
  player = [MUPlayer playerWithName: @"User" password: @"" world: world];
  
  profile = [MUProfile profileWithWorld: world player: player];
  [self assert: [profile uniqueIdentifier] equals: @"test.world.user"];
}

@end

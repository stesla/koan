//
//  MUProfileRegistry.m
//  Koan
//
//  Created by Samuel on 1/1/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "MUProfileRegistry.h"
#import "MUProfile.h"

static MUProfileRegistry * sharedRegistry = nil;

@implementation MUProfileRegistry

+ (MUProfileRegistry *) sharedRegistry
{
  if (!sharedRegistry)
    sharedRegistry = [[MUProfileRegistry alloc] init];
  return sharedRegistry;
}

- (id) init
{
  self = [super init];
  {
    profiles = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (void) dealloc
{
  [profiles release];
  [super dealloc];
}

- (MUProfile *) profileForWorld:(MUWorld *)world
{
  return [self profileForProfile:[MUProfile profileWithWorld:world]];
}

- (MUProfile *) profileForWorld:(MUWorld *)world player:(MUPlayer *)player
{
  return [self profileForProfile:[MUProfile profileWithWorld:world
                                                      player:player]];
}

- (MUProfile *) profileForProfile:(MUProfile *)profile
{
  MUProfile *rval = [profiles objectForKey:[profile uniqueIdentifier]];
  if (!rval)
  {
    rval = profile;
    [profiles setObject:rval forKey:[rval uniqueIdentifier]];    
  }
  return rval;
}

- (MUProfile *) profileForUniqueIdentifier:(NSString *)identifier
{
  return [profiles objectForKey:identifier];
}

@end

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
  MUProfile * profile = [MUProfile profileWithWorld:world];
  [profiles setObject:profile forKey:[profile windowName]];
  return profile;
}

- (MUProfile *) profileForUniqueIdentifier:(NSString *)identifier
{
  return [profiles objectForKey:identifier];
}

@end

//
//  MUProfileRegistry.m
//  Koan
//
//  Created by Samuel on 1/1/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "MUProfileRegistry.h"

static MUProfileRegistry * sharedRegistry = nil;

@implementation MUProfileRegistry

+ (MUProfileRegistry *) sharedRegistry
{
  if (!sharedRegistry)
    sharedRegistry = [[MUProfileRegistry alloc] init];
  return sharedRegistry;
}

@end

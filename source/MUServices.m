//
// MUServices.m
//
// Copyright (c) 2005 3James Software
//

#import "MUServices.h"

@implementation MUServices

+ (MUProfileRegistry *) profileRegistry
{
  return [MUProfileRegistry sharedRegistry];
}

+ (MUWorldRegistry *) worldRegistry
{
  return [MUWorldRegistry sharedRegistry];
}

@end

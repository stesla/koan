//
//  MUServices.m
//  Koan
//
//  Created by Samuel on 1/15/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
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

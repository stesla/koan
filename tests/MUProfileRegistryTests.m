//
//  MUProfileRegistryTest.m
//  Koan
//
//  Created by Samuel on 1/1/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "MUProfileRegistryTests.h"
#import "MUProfileRegistry.h"

@implementation MUProfileRegistryTests

- (void) testSharedRegistry
{
  MUProfileRegistry *registryOne, *registryTwo;
  
  registryOne = [MUProfileRegistry sharedRegistry];
  [self assertTrue:[registryOne class] == [MUProfileRegistry class]
           message:@"Class"];
  
  registryTwo = [MUProfileRegistry sharedRegistry];
  [self assertTrue:registryOne == registryTwo
           message:@"Same instance"];
}

@end

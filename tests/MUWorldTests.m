//
//  MUWorldTests.m
//  Koan
//
//  Created by Samuel on 1/2/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "MUWorldTests.h"
#import "MUWorld.h"

@implementation MUWorldTests

- (void) testUniqueIdentifier
{
  MUWorld * world = [[MUWorld alloc]
    initWithWorldName:@"Test World"
        worldHostname:@""
            worldPort:[NSNumber numberWithInt:5678]
             worldURL:@""
   connectOnAppLaunch:NO
              usesSSL:NO
        proxySettings:nil
              players:[NSArray array]];
  [self assert:[world uniqueIdentifier] equals:@"test.world"]; 
}

@end

//
//  MUPlayerTests.m
//  Koan
//
//  Created by Samuel on 1/4/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "MUPlayerTests.h"
#import "MUPlayer.h"

@implementation MUPlayerTests

- (void) testQuotedUsername
{
  MUPlayer *player = [[[MUPlayer alloc] initWithName:@"My User"
                                            password:@"password"
                                  connectOnAppLaunch:NO
                                               world:nil] autorelease];
  [self assert:[player loginString] 
        equals:@"connect \"My User\" password"];
}

@end

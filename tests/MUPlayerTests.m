//
// MUPlayerTests.m
//
// Copyright (C) 2005 3James Software
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

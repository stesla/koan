//
// MUPlayerTests.m
//
// Copyright (c) 2005 3James Software
//

#import "MUPlayerTests.h"
#import "MUPlayer.h"

@implementation MUPlayerTests

- (void) testQuotedUsername
{
  MUPlayer *player = [[[MUPlayer alloc] initWithName:@"My User"
                                            password:@"password"
                                               world:nil] autorelease];
  
  [self assert:[player loginString]
        equals:@"connect \"My User\" password"];
}

- (void) testNoQuotesForSingleWordUsername
{
  MUPlayer *player = [[[MUPlayer alloc] initWithName:@"Bob"
                                            password:@"drowssap"
                                               world:nil] autorelease];
  [self assert:[player loginString]
        equals:@"connect Bob drowssap"];
}

@end

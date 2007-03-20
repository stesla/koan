//
// MUPlayerTests.m
//
// Copyright (c) 2005, 2006, 2007 3James Software
//

#import "MUPlayerTests.h"
#import "MUPlayer.h"

@implementation MUPlayerTests

- (void) testLoginStringHasQuotesForMultiwordUsername
{
  MUPlayer *player = [MUPlayer playerWithName:@"My User"
  																	 password:@"password"
  																			world:nil];
  
  [self assert:[player loginString]
        equals:@"connect \"My User\" password"];
}

- (void) testLoginStringHasNoQuotesForSingleWordUsername
{
  MUPlayer *player = [MUPlayer playerWithName:@"Bob"
  																	 password:@"drowssap"
  																			world:nil];
  [self assert:[player loginString]
        equals:@"connect Bob drowssap"];
}

- (void) testLoginStringWithNilPassword
{
  MUPlayer *player = [MUPlayer playerWithName:@"guest"
  																	 password:nil
  																			world:nil];
  [self assert:[player loginString]
  			equals:@"connect guest"];
}

- (void) testLoginStringWithZeroLengthPassword
{
  MUPlayer *player = [MUPlayer playerWithName:@"guest"
  																	 password:@""
  																			world:nil];
  [self assert:[player loginString]
  			equals:@"connect guest"];
}

- (void) testNoLoginStringForNilPlayerName
{
  MUPlayer *playerOne = [MUPlayer playerWithName:nil
  																			password:nil
  																				 world:nil];
  [self assertNil:[playerOne loginString]];
  
  MUPlayer *playerTwo = [MUPlayer playerWithName:nil
  																			password:@"nonsense"
  																				 world:nil];
  [self assertNil:[playerTwo loginString]];
}

@end

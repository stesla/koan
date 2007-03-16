//
// MUPlayerTests.m
//
// Copyright (c) 2005, 2007 3James Software
//

#import "MUPlayerTests.h"
#import "MUPlayer.h"

@implementation MUPlayerTests

- (void) testLoginStringHasQuotesForMultiwordUsername
{
  MUPlayer *player = [[[MUPlayer alloc] initWithName:@"My User"
                                            password:@"password"
                                               world:nil] autorelease];
  
  [self assert:[player loginString]
        equals:@"connect \"My User\" password"];
}

- (void) testLoginStringHasNoQuotesForSingleWordUsername
{
  MUPlayer *player = [[[MUPlayer alloc] initWithName:@"Bob"
                                            password:@"drowssap"
                                               world:nil] autorelease];
  [self assert:[player loginString]
        equals:@"connect Bob drowssap"];
}

- (void) testLoginStringWithNilPassword
{
	MUPlayer *player = [[[MUPlayer alloc] initWithName:@"guest"
																						password:nil
																							 world:nil] autorelease];
	[self assert:[player loginString]
				equals:@"connect guest"];
}

- (void) testLoginStringWithZeroLengthPassword
{
	MUPlayer *player = [[[MUPlayer alloc] initWithName:@"guest"
																						password:@""
																							 world:nil] autorelease];
	[self assert:[player loginString]
				equals:@"connect guest"];
}

- (void) testNoLoginStringForNilPlayerName
{
	MUPlayer *playerOne = [[[MUPlayer alloc] initWithName:nil
																						password:nil
																							 world:nil] autorelease];
	[self assert:[playerOne loginString]
				equals:nil];
	
	MUPlayer *playerTwo = [[[MUPlayer alloc] initWithName:nil
																							 password:@"nonsense"
																									world:nil] autorelease];
	[self assert:[playerTwo loginString]
				equals:nil];
}

@end

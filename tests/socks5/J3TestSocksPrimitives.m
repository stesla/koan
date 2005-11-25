//
//  J3TestSocks5Primitives.m
//  Koan
//
//  Created by Samuel Tesla on 11/22/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "J3Buffer.h"
#import "J3TestSocksPrimitives.h"
#import "J3SocksConstants.h"
#import "J3SocksMethodSelection.h"

@interface J3TestSocksPrimitives (Private)

- (void) assertSelection:(J3SocksMethodSelection *)selection writes:(NSString *)output;

@end

#pragma mark -

@implementation J3TestSocksPrimitives

- (void) setUp
{
  buffer = [[J3Buffer alloc] init];
}

- (void) tearDown
{
  [buffer release];
}

- (void) testMethodSelection;
{
  J3SocksMethodSelection * selection = [[[J3SocksMethodSelection alloc] init] autorelease];
  [self assertSelection:selection writes:@"\x05\x01\x00"];
  [selection addMethod:J3SocksUsernamePassword];
  [self assertSelection:selection writes:@"\x05\x02\x00\x02"];
}

@end

#pragma mark -

@implementation J3TestSocksPrimitives (Private)

- (void) assertSelection:(J3SocksMethodSelection *)selection writes:(NSString *)output;
{
  [buffer clear];
  [selection appendToBuffer:buffer];
  [self assert:[buffer stringValue] equals:output];  
}

@end


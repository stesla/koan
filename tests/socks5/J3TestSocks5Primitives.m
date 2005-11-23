//
//  J3TestSocks5Primitives.m
//  Koan
//
//  Created by Samuel Tesla on 11/22/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "J3Buffer.h"
#import "J3TestSocks5Primitives.h"
#import "J3Socks5Constants.h"
#import "J3Socks5MethodSelection.h"

@interface J3TestSocks5Primitives (Private)

- (void) assertSelection:(J3Socks5MethodSelection *)selection writes:(NSString *)output;

@end

@implementation J3TestSocks5Primitives
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
  J3Socks5MethodSelection * selection = [[[J3Socks5MethodSelection alloc] init] autorelease];
  [self assertSelection:selection writes:@"\x05\x01\x00"];
  [selection addMethod:J3Socks5UsernamePassword];
  [self assertSelection:selection writes:@"\x05\x02\x00\x02"];
}

@end

@implementation J3TestSocks5Primitives (Private)

- (void) assertSelection:(J3Socks5MethodSelection *)selection writes:(NSString *)output;
{
  [buffer clear];
  [selection appendToBuffer:buffer];
  [self assert:[buffer stringValue] equals:output];  
}

@end


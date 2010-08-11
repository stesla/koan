//
// J3Protocol.m
//
// Copyright (c) 2010 3James Software.
//

#import "J3Protocol.h"

@implementation J3Protocol

+ (id) protocol
{
  return [[[self alloc] init] autorelease];
}

@end

#pragma mark -

@implementation J3ProtocolStack

- (void) addProtocol: (J3Protocol *) protocol
{
  
}

- (void) clearProtocols
{
  
}

@end

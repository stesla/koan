//
//  J3TelnetByteDestination.m
//
// Copyright (c) 2007 3James Software
//


#import "J3TelnetByteDestination.h"


@implementation J3TelnetByteDestination

+ (id) destination;
{
  return [[[self alloc] init] autorelease];
}

- (void) setDestination: (NSObject <J3ByteDestination> *) newDestination;
{
  [self at: &destination put: newDestination];
}

#pragma mark -
#pragma mark J3ByteDestination protocol

- (BOOL) hasSpaceAvailable;
{
  return [destination hasSpaceAvailable];
}

- (unsigned) write: (const uint8_t *)bytes length: (unsigned)length;
{
  return [destination write: bytes length: length];
}

@end


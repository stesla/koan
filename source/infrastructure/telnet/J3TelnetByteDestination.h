//
//  J3TelnetByteDestination.h
//
// Copyright (c) 2007 3James Software
//


#import <Cocoa/Cocoa.h>
#import "J3ByteDestination.h"


@interface J3TelnetByteDestination : NSObject <J3ByteDestination>
{
  NSObject <J3ByteDestination> *destination;
}

+ (id) destination;

- (void) setDestination: (NSObject <J3ByteDestination> *) newDestination;

@end

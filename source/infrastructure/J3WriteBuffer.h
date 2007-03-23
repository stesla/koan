//
// J3WriteBuffer.h
//
// Copyright (c) 2005, 2006, 2007 3James Software
//

#import <Cocoa/Cocoa.h>
#import "J3Buffer.h"

@protocol J3ByteDestination;

@interface J3WriteBufferException : NSException

@end

#pragma mark -

@interface J3WriteBuffer : J3Buffer
{
  NSObject <J3ByteDestination> *destination;
}

- (void) flush;
- (void) setByteDestination: (NSObject <J3ByteDestination> *) object;

@end

//
// J3WriteBuffer.h
//
// Copyright (c) 2005, 2006, 2007 3James Software
//

#import <Cocoa/Cocoa.h>
#import "J3Buffer.h"
#import "J3ByteDestination.h"

@interface J3WriteBufferException : NSException

@end

#pragma mark -

@interface J3WriteBuffer : J3Buffer <J3ByteDestination> 
{
  NSObject <J3ByteDestination> *destination;
}

- (void) flush;
- (void) setByteDestination: (NSObject <J3ByteDestination> *)object;

@end

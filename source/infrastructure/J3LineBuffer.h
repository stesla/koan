//
// J3LineBuffer.h
//
// Copyright (c) 2005 3James Software
//

#import <Cocoa/Cocoa.h>
#import "J3Buffer.h"

@class J3LineBuffer;

@protocol J3LineBufferDelegate

- (void) lineBufferHasReadLine:(J3LineBuffer *)buffer;

@end

#pragma mark -

@interface J3LineBuffer : J3Buffer
{
  NSObject <J3LineBufferDelegate> *delegate;
}

- (NSString *) readLine;
- (void) setDelegate:(NSObject <J3LineBufferDelegate> *)object;

@end

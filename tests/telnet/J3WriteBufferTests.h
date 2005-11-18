//
// J3WriteBufferTests.h
//
// Copyright (c) 2005 3James Software
//

#import <Cocoa/Cocoa.h>
#import "J3ByteDestination.h"

@class J3WriteBuffer;

@interface J3WriteBufferTests : TestCase <J3ByteDestination>
{
  J3WriteBuffer *buffer;
  unsigned lengthWritten;
  NSMutableData *output;
}

@end

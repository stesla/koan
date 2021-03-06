//
// J3WriteBufferTests.h
//
// Copyright (c) 2010 3James Software.
//

#import <Cocoa/Cocoa.h>
#import <J3Testing/J3Testcase.h>

#import "J3ByteDestination.h"

@class J3WriteBuffer;

@interface J3WriteBufferTests : J3TestCase <J3ByteDestination>
{
  J3WriteBuffer *buffer;
  NSMutableData *output;
}

@end

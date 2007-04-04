//
// J3SOCKSPrimitiveTests.h
//
// Copyright (c) 2007 3James Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <J3Testing/J3Testcase.h>

@class J3WriteBuffer;

@interface J3SOCKSPrimitiveTests : J3TestCase
{
  J3WriteBuffer *buffer;
  NSString *readString;
}

@end

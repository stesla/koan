//
// J3LineBufferTests.h
//
// Copyright (c) 2005, 2006 3James Software
//

#import <Cocoa/Cocoa.h>
#import <J3Testing/J3Testcase.h>
#import "J3LineBuffer.h"

@interface J3LineBufferTests : J3TestCase <J3ByteDestination>
{
  NSString *line;
  J3LineBuffer *buffer;
}

@end

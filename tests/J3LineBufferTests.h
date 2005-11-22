//
// J3LineBufferTests.h
//
// Copyright (c) 2005 3James Software
//

#import <Cocoa/Cocoa.h>
#import <ObjcUnit/ObjcUnit.h>
#import "J3LineBuffer.h"

@interface J3LineBufferTests : TestCase <J3LineBufferDelegate>
{
  NSString *line;
  J3LineBuffer *buffer;
}

@end

//
// J3TextLoggerTests.h
//
// Copyright (c) 2004, 2005 3James Software
//

#import <Cocoa/Cocoa.h>
#import <ObjcUnit/ObjcUnit.h>

#import "J3TextLogger.h"

#define J3TextLogTestBufferMax 1024

@interface J3TextLoggerTests : TestCase
{
  J3TextLogger *filter;
  uint8_t outputBuffer[1024];
}

@end

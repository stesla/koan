//
// J3TextLoggerTests.h
//
// Copyright (c) 2004, 2005 3James Software
//

#import <Cocoa/Cocoa.h>
#import <J3Testing/J3Testcase.h>

#import "J3TextLogger.h"

#define J3TextLogTestBufferMax 1024

@interface J3TextLoggerTests : J3TestCase
{
  J3TextLogger *filter;
  uint8_t outputBuffer[1024];
}

@end

//
// MUTextLoggerTests.h
//
// Copyright (c) 2007 3James Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <J3Testing/J3Testcase.h>

#import "MUTextLogger.h"

#define J3TextLogTestBufferMax 1024

@interface MUTextLoggerTests : J3TestCase
{
  MUTextLogger *filter;
  uint8_t outputBuffer[1024];
}

@end

//
// MUTextLoggerTests.h
//
// Copyright (C) 2004 3James Software
//

#import <Cocoa/Cocoa.h>
#import <ObjcUnit/ObjcUnit.h>

#import "MUTextLogger.h"

#define MUTextLogTestBufferMax 1024

@interface MUTextLoggerTests : TestCase
{
  MUTextLogger *filter;
  uint8_t outputBuffer[1024];
}

@end

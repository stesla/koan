//
// MUTextLogFilterTests.h
//
// Copyright (C) 2004 3James Software
//

#import <Cocoa/Cocoa.h>
#import <ObjcUnit/ObjcUnit.h>

#import "MUTextLogFilter.h"

#define MUTextLogTestBufferMax 1024

@interface MUTextLogFilterTests : TestCase
{
  MUTextLogFilter *filter;
  uint8_t outputBuffer[1024];
}

@end

//
// J3TelnetStateMachineTests.h
//
// Copyright (c) 2010 3James Software.
//

#import <Cocoa/Cocoa.h>
#import <J3Testing/J3Testcase.h>
#import "J3TelnetEngine.h"

@interface J3TelnetStateMachineTests : J3TestCase <J3TelnetEngineDelegate>
{
  J3TelnetEngine *engine;
  int lastByteInput;
  NSMutableData *output;
}
@end

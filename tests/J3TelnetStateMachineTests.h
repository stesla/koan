//
// J3TelnetStateMachineTests.h
//
// Copyright (c) 2007 3James Software.
//

#import <Cocoa/Cocoa.h>
#import <J3Testing/J3Testcase.h>
#import "J3TelnetEngine.h"

@class J3WriteBuffer;

@interface J3MockTelnetEngine : J3TelnetEngine
{
  uint8_t lastByteInput;
  J3WriteBuffer * output;
}

- (uint8_t) lastByteInput;
- (uint8_t) outputByteAtIndex: (unsigned) index;
- (unsigned) outputLength;

@end

@interface J3TelnetStateMachineTests : J3TestCase
{
  J3TelnetState * state;
  J3MockTelnetEngine * engine;
}
@end

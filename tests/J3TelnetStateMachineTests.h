//
// J3TelnetStateMachineTests.h
//
// Copyright (c) 2010 3James Software.
//

#import <Cocoa/Cocoa.h>
#import <J3Testing/J3Testcase.h>
#import "J3TelnetProtocolHandler.h"
#import "J3TelnetStateMachine.h"

@interface J3TelnetStateMachineTests : J3TestCase <J3TelnetProtocolHandler>
{
  J3TelnetStateMachine *stateMachine;
  int lastByteInput;
  NSMutableData *output;
}
@end

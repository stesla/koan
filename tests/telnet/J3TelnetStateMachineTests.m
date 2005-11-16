//
//  StateMachineTests.m
//  NewTelnet
//
//  Created by Samuel Tesla on 11/9/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "J3TelnetStateMachineTests.h"
#import "J3TelnetConstants.h"
#import "J3TelnetInterpretAsCommandState.h"
#import "J3TelnetParser.h"
#import "J3TelnetTextState.h"
#import "J3TelnetDoState.h"
#import "J3TelnetDontState.h"
#import "J3TelnetWillState.h"
#import "J3TelnetWontState.h"

#define C(x) ([x class])

@interface J3MockTelnetParser : J3TelnetParser
{
  uint8_t lastByteInput;
  uint8_t lastByteOutput;
}
- (uint8_t) lastByteInput;
- (uint8_t) lastByteOutput;
@end

@interface J3TelnetStateMachineTests (Private)
- (void) assertState:(Class)stateClass givenByte:(uint8_t)byte producesState:(Class)nextStateClass;
- (void) assertState:(Class)stateClass givenByte:(uint8_t)givenByte inputsByte:(uint8_t)inputsByte;
- (void) assertState:(Class)stateClass givenByte:(uint8_t)givenByte outputsByte:(uint8_t)outputsByte;
@end

@implementation J3TelnetStateMachineTests
- (void) testTextStateTransitions
{
  [self assertState:C(J3TelnetTextState) givenByte:'a' producesState:C(J3TelnetTextState)];
  [self assertState:C(J3TelnetTextState) givenByte:J3TelnetInterpretAsCommand producesState:C(J3TelnetInterpretAsCommandState)];
}

- (void) testInterpretAsCommandStateTransitions
{
  [self assertState:C(J3TelnetInterpretAsCommandState) givenByte:'a' producesState:C(J3TelnetTextState)];
  [self assertState:C(J3TelnetInterpretAsCommandState) givenByte:J3TelnetInterpretAsCommand producesState:C(J3TelnetTextState)];
  [self assertState:C(J3TelnetInterpretAsCommandState) givenByte:J3TelnetDo producesState:C(J3TelnetDoState)];
  [self assertState:C(J3TelnetInterpretAsCommandState) givenByte:J3TelnetDont producesState:C(J3TelnetDontState)];
  [self assertState:C(J3TelnetInterpretAsCommandState) givenByte:J3TelnetWill producesState:C(J3TelnetWillState)];
  [self assertState:C(J3TelnetInterpretAsCommandState) givenByte:J3TelnetWont producesState:C(J3TelnetWontState)];  
}
  
- (void) testDoWontWillWontStateTransitions
{
  [self assertState:C(J3TelnetDoState) givenByte:'a' producesState:C(J3TelnetTextState)];
  [self assertState:C(J3TelnetDontState) givenByte:'a' producesState:C(J3TelnetTextState)];
  [self assertState:C(J3TelnetWillState) givenByte:'a' producesState:C(J3TelnetTextState)];
  [self assertState:C(J3TelnetWontState) givenByte:'a' producesState:C(J3TelnetTextState)];
}

- (void) testInput
{
  [self assertState:C(J3TelnetTextState) givenByte:'a' inputsByte:'a'];
  [self assertState:C(J3TelnetInterpretAsCommandState) givenByte:J3TelnetInterpretAsCommand inputsByte:J3TelnetInterpretAsCommand];
}

- (void) testOutput
{
  [self assertState:C(J3TelnetDoState) givenByte:'a' outputsByte:J3TelnetWont];
  [self assertState:C(J3TelnetDontState) givenByte:'a' outputsByte:J3TelnetWont];
  [self assertState:C(J3TelnetWillState) givenByte:'a' outputsByte:J3TelnetDont];
  [self assertState:C(J3TelnetWontState) givenByte:'a' outputsByte:J3TelnetDont];
}
@end

@implementation J3TelnetStateMachineTests (Private)
- (void) assertState:(Class)stateClass givenByte:(uint8_t)byte producesState:(Class)nextStateClass;
{
  J3TelnetState * state = [[[stateClass alloc] init] autorelease];
  J3TelnetState * nextState = [state parse:byte forParser:nil];
  [self assert:[nextState class] equals:nextStateClass];  
}

- (void) assertState:(Class)stateClass givenByte:(uint8_t)givenByte inputsByte:(uint8_t)inputsByte;
{
  J3TelnetState * state = [[[stateClass alloc] init] autorelease];
  J3MockTelnetParser * parser = [J3MockTelnetParser parser];
  [state parse:givenByte forParser:parser];
  [self assertInt:[parser lastByteInput] equals:inputsByte];
}

- (void) assertState:(Class)stateClass givenByte:(uint8_t)givenByte outputsByte:(uint8_t)outputsByte;
{
  J3TelnetState * state = [[[stateClass alloc] init] autorelease];
  J3MockTelnetParser * parser = [J3MockTelnetParser parser];
  [state parse:givenByte forParser:parser];
  [self assertInt:[parser lastByteOutput] equals:outputsByte];
}
@end

@implementation J3MockTelnetParser
- (uint8_t) lastByteInput;
{
  return lastByteInput;
}

- (uint8_t) lastByteOutput;
{
  return lastByteOutput;
}

- (void) bufferInputByte:(uint8_t)byte;
{
  lastByteInput = byte;
}

- (void) bufferOutputByte:(uint8_t)byte;
{
  lastByteOutput = byte;
}
@end


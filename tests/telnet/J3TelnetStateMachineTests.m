//
// J3TelnetStateMachineTests.m
//
// Copyright (c) 2005 3James Software
//

#import "J3TelnetStateMachineTests.h"
#import "J3TelnetConstants.h"
#import "J3TelnetInterpretAsCommandState.h"
#import "J3TelnetTextState.h"
#import "J3TelnetDoState.h"
#import "J3TelnetDontState.h"
#import "J3TelnetWillState.h"
#import "J3TelnetWontState.h"
#import "J3WriteBuffer.h"

#define C(x) ([x class])

#pragma mark -

@implementation J3MockTelnetParser

- (id) init;
{
  if (![super init])
    return nil;
  [self at:&output put:[J3WriteBuffer buffer]];
  return self;
}

- (uint8_t) lastByteInput;
{
  return lastByteInput;
}

- (uint8_t) outputByteAtIndex:(unsigned)index;
{
  const uint8_t * bytes = [output bytes];
  return bytes[index];
}

- (unsigned) outputLength;
{
  return [output length];
}

- (void) bufferInputByte:(uint8_t)byte;
{
  lastByteInput = byte;
}

- (void) bufferOutputByte:(uint8_t)byte;
{
  [output append:byte];
}

@end

#pragma mark -

@interface J3TelnetStateMachineTests (Private)

- (void) assertState:(Class)stateClass givenAnyByteProducesState:(Class)nextStateClass;
- (void) assertState:(Class)stateClass givenByte:(uint8_t)byte producesState:(Class)nextStateClass;
- (void) assertState:(Class)stateClass hasNoOutputGivenByte:(uint8_t)givenByte;
- (void) assertState:(Class)stateClass givenByte:(uint8_t)givenByte inputsByte:(uint8_t)inputsByte;
- (void) assertState:(Class)stateClass givenByte:(uint8_t)givenByte outputsNegtiationCommandWithThatByte:(uint8_t)outputsCommand;
- (void) assertStateHasNoOutputGivenAnyByte:(Class)stateClass;
- (void) giveStateClass:(Class)stateClass byte:(uint8_t)byte;
- (void) setStateClass:(Class)stateClass;

@end

#pragma mark -

@implementation J3TelnetStateMachineTests

- (void) testTextStateTransitions
{
  [self assertState:C(J3TelnetTextState) givenAnyByteProducesState:C(J3TelnetTextState)];
  [self assertState:C(J3TelnetTextState) givenByte:J3TelnetInterpretAsCommand producesState:C(J3TelnetInterpretAsCommandState)];
}

- (void) testInterpretAsCommandStateTransitions
{
  [self assertState:C(J3TelnetInterpretAsCommandState) givenAnyByteProducesState:C(J3TelnetTextState)];
  [self assertState:C(J3TelnetInterpretAsCommandState) givenByte:J3TelnetInterpretAsCommand producesState:C(J3TelnetTextState)];
  [self assertState:C(J3TelnetInterpretAsCommandState) givenByte:J3TelnetDo producesState:C(J3TelnetDoState)];
  [self assertState:C(J3TelnetInterpretAsCommandState) givenByte:J3TelnetDont producesState:C(J3TelnetDontState)];
  [self assertState:C(J3TelnetInterpretAsCommandState) givenByte:J3TelnetWill producesState:C(J3TelnetWillState)];
  [self assertState:C(J3TelnetInterpretAsCommandState) givenByte:J3TelnetWont producesState:C(J3TelnetWontState)];  
}
  
- (void) testDoWontWillWontStateTransitions
{
  [self assertState:C(J3TelnetDoState) givenAnyByteProducesState:C(J3TelnetTextState)];
  [self assertState:C(J3TelnetDontState) givenAnyByteProducesState:C(J3TelnetTextState)];
  [self assertState:C(J3TelnetWillState) givenAnyByteProducesState:C(J3TelnetTextState)];
  [self assertState:C(J3TelnetWontState) givenAnyByteProducesState:C(J3TelnetTextState)];
}

- (void) testInput
{
  [self assertState:C(J3TelnetTextState) givenByte:'a' inputsByte:'a'];
  [self assertState:C(J3TelnetInterpretAsCommandState) givenByte:J3TelnetInterpretAsCommand inputsByte:J3TelnetInterpretAsCommand];
}

- (void) testNegotiationAlwaysNVT
{
  [self assertState:C(J3TelnetDoState) givenByte:'a' outputsNegtiationCommandWithThatByte:J3TelnetWont];
  [self assertState:C(J3TelnetWillState) givenByte:'a' outputsNegtiationCommandWithThatByte:J3TelnetDont];  
  [self assertStateHasNoOutputGivenAnyByte:C(J3TelnetDontState)]; 
  [self assertStateHasNoOutputGivenAnyByte:C(J3TelnetWontState)];
}
@end

#pragma mark -

@implementation J3TelnetStateMachineTests (Private)

- (void) assertState:(Class)stateClass givenAnyByteProducesState:(Class)nextStateClass;
{
  [self assertState:stateClass givenByte:'a' producesState:nextStateClass];
}

- (void) assertState:(Class)stateClass givenByte:(uint8_t)byte producesState:(Class)nextStateClass;
{
  J3TelnetState * nextState;
  [self setStateClass:stateClass];
  nextState = [state parse:byte forParser:nil];
  [self assert:[nextState class] equals:nextStateClass];  
}

- (void) assertState:(Class)stateClass hasNoOutputGivenByte:(uint8_t)givenByte;
{
  [self giveStateClass:stateClass byte:givenByte];
  [self assertInt:[parser outputLength] equals:0];
}

- (void) assertState:(Class)stateClass givenByte:(uint8_t)givenByte inputsByte:(uint8_t)inputsByte;
{
  [self giveStateClass:stateClass byte:givenByte];
  [self assertInt:[parser lastByteInput] equals:inputsByte];
}

- (void) assertState:(Class)stateClass givenByte:(uint8_t)givenByte outputsNegtiationCommandWithThatByte:(uint8_t)outputsCommand;
{
  [self giveStateClass:stateClass byte:givenByte];
  [self assertInt:[parser outputLength] equals:3];
  [self assertInt:[parser outputByteAtIndex:0] equals:J3TelnetInterpretAsCommand];
  [self assertInt:[parser outputByteAtIndex:1] equals:outputsCommand];
  [self assertInt:[parser outputByteAtIndex:2] equals:givenByte];
}

- (void) assertStateHasNoOutputGivenAnyByte:(Class)stateClass;
{
  [self assertState:stateClass hasNoOutputGivenByte:'a'];
}

- (void) giveStateClass:(Class)stateClass byte:(uint8_t)byte;
{
  [self setStateClass:stateClass];
  parser = [J3MockTelnetParser parser];
  [state parse:byte forParser:parser];  
}

- (void) setStateClass:(Class)stateClass;
{
  state = [[[stateClass alloc] init] autorelease];  
}

@end

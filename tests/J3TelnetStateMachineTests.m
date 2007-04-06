//
// J3TelnetStateMachineTests.m
//
// Copyright (c) 2007 3James Software.
//

#import "J3TelnetStateMachineTests.h"
#import "J3TelnetConstants.h"
#import "J3TelnetInterpretAsCommandState.h"
#import "J3TelnetTextState.h"
#import "J3TelnetDoState.h"
#import "J3TelnetDontState.h"
#import "J3TelnetOptionMCCP1State.h"
#import "J3TelnetSubnegotiationInterpretAsCommandState.h"
#import "J3TelnetSubnegotiationState.h"
#import "J3TelnetWillState.h"
#import "J3TelnetWontState.h"
#import "J3WriteBuffer.h"

#define C(x) ([x class])

#pragma mark -

@implementation J3MockTelnetEngine

- (id) init;
{
  if (![super init])
    return nil;
  [self at: &output put: [J3WriteBuffer buffer]];
  return self;
}

- (uint8_t) lastByteInput;
{
  return lastByteInput;
}

- (uint8_t) outputByteAtIndex: (unsigned) index;
{
  return ((uint8_t *)[[output dataValue] bytes])[index];
}

- (unsigned) outputLength;
{
  return [output length];
}

- (void) bufferInputByte: (uint8_t) byte;
{
  lastByteInput = byte;
}

- (void) bufferOutputByte: (uint8_t) byte;
{
  [output appendByte: byte];
}

@end

#pragma mark -

@interface J3TelnetStateMachineTests (Private)

- (void) assertState: (Class) stateClass givenAnyByteProducesState: (Class) nextStateClass;
- (void) assertState: (Class) stateClass givenByte: (uint8_t) byte producesState: (Class) nextStateClass;
- (void) assertState: (Class) stateClass hasNoOutputGivenByte: (uint8_t) givenByte;
- (void) assertState: (Class) stateClass givenByte: (uint8_t) givenByte inputsByte: (uint8_t) inputsByte;
- (void) assertState: (Class) stateClass givenByte: (uint8_t) givenByte outputsNegtiationCommandWithThatByte: (uint8_t) outputsCommand;
- (void) assertStateHasNoOutputGivenAnyByte: (Class) stateClass;
- (void) giveStateClass: (Class) stateClass byte: (uint8_t) byte;
- (void) setStateClass: (Class) stateClass;

@end

#pragma mark -

@implementation J3TelnetStateMachineTests

- (void) testTextStateTransitions
{
  [self assertState: C(J3TelnetTextState) givenAnyByteProducesState: C(J3TelnetTextState)];
  [self assertState: C(J3TelnetTextState) givenByte: J3TelnetInterpretAsCommand producesState: C(J3TelnetInterpretAsCommandState)];
}

- (void) testInterpretAsCommandStateTransitions
{
  [self assertState: C(J3TelnetInterpretAsCommandState) givenAnyByteProducesState: C(J3TelnetTextState)];
  [self assertState: C(J3TelnetInterpretAsCommandState) givenByte: J3TelnetInterpretAsCommand producesState: C(J3TelnetTextState)];
  [self assertState: C(J3TelnetInterpretAsCommandState) givenByte: J3TelnetDo producesState: C(J3TelnetDoState)];
  [self assertState: C(J3TelnetInterpretAsCommandState) givenByte: J3TelnetDont producesState: C(J3TelnetDontState)];
  [self assertState: C(J3TelnetInterpretAsCommandState) givenByte: J3TelnetWill producesState: C(J3TelnetWillState)];
  [self assertState: C(J3TelnetInterpretAsCommandState) givenByte: J3TelnetWont producesState: C(J3TelnetWontState)];  
  [self assertState: C(J3TelnetInterpretAsCommandState) givenByte: J3TelnetBeginSubnegotiation producesState: C(J3TelnetSubnegotiationState)];
}
  
- (void) testDoWontWillWontStateTransitions
{
  [self assertState: C(J3TelnetDoState) givenAnyByteProducesState: C(J3TelnetTextState)];
  [self assertState: C(J3TelnetDontState) givenAnyByteProducesState: C(J3TelnetTextState)];
  [self assertState: C(J3TelnetWillState) givenAnyByteProducesState: C(J3TelnetTextState)];
  [self assertState: C(J3TelnetWontState) givenAnyByteProducesState: C(J3TelnetTextState)];
}

- (void) testInput
{
  [self assertState: C(J3TelnetTextState) givenByte: 'a' inputsByte: 'a'];
  [self assertState: C(J3TelnetInterpretAsCommandState) givenByte: J3TelnetInterpretAsCommand inputsByte: J3TelnetInterpretAsCommand];
}

#ifdef TYLER_WILL_FIX
- (void) testNegotiationAlwaysNVT
{
  [self assertState: C(J3TelnetDoState) givenByte: 'a' outputsNegtiationCommandWithThatByte: J3TelnetWont];
  [self assertState: C(J3TelnetWillState) givenByte: 'a' outputsNegtiationCommandWithThatByte: J3TelnetDont];  
  [self assertStateHasNoOutputGivenAnyByte: C(J3TelnetDontState)];
  [self assertStateHasNoOutputGivenAnyByte: C(J3TelnetWontState)];
}
#endif

- (void) testSubnegotiationStateTransitions
{
  [self assertState: C(J3TelnetSubnegotiationState) givenAnyByteProducesState: C(J3TelnetSubnegotiationState)];
  [self assertState: C(J3TelnetSubnegotiationState) givenByte: J3TelnetInterpretAsCommand producesState: C(J3TelnetSubnegotiationInterpretAsCommandState)];
  [self assertState: C(J3TelnetSubnegotiationInterpretAsCommandState) givenAnyByteProducesState: C(J3TelnetSubnegotiationState)];
  [self assertState: C(J3TelnetSubnegotiationInterpretAsCommandState) givenByte: J3TelnetEndSubnegotiation producesState: C(J3TelnetTextState)];
}

- (void) testMCCP1NegotiationStateTransitions
{
  [self assertState: C(J3TelnetSubnegotiationState) givenByte: J3TelnetOptionMCCP1 producesState: C(J3TelnetOptionMCCP1State)];
  [self assertState: C(J3TelnetOptionMCCP1State) givenByte: J3TelnetWill producesState: C(J3TelnetSubnegotiationInterpretAsCommandState)];
}

@end

#pragma mark -

@implementation J3TelnetStateMachineTests (Private)

- (void) assertState: (Class) stateClass givenAnyByteProducesState: (Class) nextStateClass;
{
  [self assertState: stateClass givenByte: 'a' producesState: nextStateClass];
}

- (void) assertState: (Class) stateClass givenByte: (uint8_t) byte producesState: (Class) nextStateClass;
{
  J3TelnetState * nextState;
  [self setStateClass: stateClass];
  nextState = [state parse: byte forParser: nil];
  [self assert: [nextState class] equals: nextStateClass];  
}

- (void) assertState: (Class) stateClass hasNoOutputGivenByte: (uint8_t) givenByte;
{
  [self giveStateClass: stateClass byte: givenByte];
  [self assertInt: [engine outputLength] equals: 0];
}

- (void) assertState: (Class) stateClass givenByte: (uint8_t) givenByte inputsByte: (uint8_t) inputsByte;
{
  [self giveStateClass: stateClass byte: givenByte];
  [self assertInt: [engine lastByteInput] equals: inputsByte];
}

- (void) assertState: (Class) stateClass givenByte: (uint8_t) givenByte outputsNegtiationCommandWithThatByte: (uint8_t) outputsCommand;
{
  [self giveStateClass: stateClass byte: givenByte];
  [self assertInt: [engine outputLength] equals: 3];
  [self assertInt: [engine outputByteAtIndex: 0] equals: J3TelnetInterpretAsCommand];
  [self assertInt: [engine outputByteAtIndex: 1] equals: outputsCommand];
  [self assertInt: [engine outputByteAtIndex: 2] equals: givenByte];
}

- (void) assertStateHasNoOutputGivenAnyByte: (Class) stateClass;
{
  [self assertState: stateClass hasNoOutputGivenByte: 'a'];
}

- (void) giveStateClass: (Class) stateClass byte: (uint8_t) byte;
{
  [self setStateClass: stateClass];
  engine = [J3MockTelnetEngine engine];
  [state parse: byte forParser: engine];  
}

- (void) setStateClass: (Class) stateClass;
{
  state = [[[stateClass alloc] init] autorelease];  
}

@end

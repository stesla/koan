//
// J3TelnetStateMachineTests.m
//
// Copyright (c) 2010 3James Software.
//

#import "J3TelnetStateMachineTests.h"
#import "J3ByteSet.h"
#import "J3TelnetConstants.h"
#import "J3TelnetIACState.h"
#import "J3TelnetTextState.h"
#import "J3TelnetDoState.h"
#import "J3TelnetDontState.h"
#import "J3TelnetNotTelnetState.h"
#import "J3TelnetMCCP1SubnegotiationState.h"
#import "J3TelnetSubnegotiationIACState.h"
#import "J3TelnetSubnegotiationOptionState.h"
#import "J3TelnetSubnegotiationState.h"
#import "J3TelnetWillState.h"
#import "J3TelnetWontState.h"
#import "J3WriteBuffer.h"

#define C(x) ([x class])

@interface J3TelnetStateMachineTests (Private)

- (void) assertByteConfirmsTelnet: (uint8_t) byte;
- (void) assertByteInvalidatesTelnet: (uint8_t) byte;
- (void) assertState: (Class) stateClass givenAnyByteProducesState: (Class) nextStateClass;
- (void) assertState: (Class) stateClass givenAnyByteProducesState: (Class) nextStateClass exceptForThoseInSet: (J3ByteSet *) exclusions;
- (void) assertState: (Class) stateClass givenByte: (uint8_t) byte producesState: (Class) nextStateClass;
- (void) assertState: (Class) stateClass givenByte: (uint8_t) givenByte inputsByte: (uint8_t) inputsByte;
- (void) assertStateObject: (J3TelnetState *) state givenAnyByteProducesState: (Class) nextStateClass exceptForThoseInSet: (J3ByteSet *) exclusions;
- (void) assertStateObject: (J3TelnetState *) state givenByte: (uint8_t) byte producesState: (Class) nextStateClass;
- (void) giveStateClass: (Class) stateClass byte: (uint8_t) byte;
- (void) resetEngine;

@end

#pragma mark -

@implementation J3TelnetStateMachineTests

- (void) setUp
{
  [self resetEngine];
  lastByteInput = -1;
  [self at: &output put: [NSMutableData data]];
}

- (void) tearDown
{
  [output release];
  [engine release];
}

- (void) testTextStateTransitions
{
  [self assertState: C(J3TelnetTextState) givenAnyByteProducesState: C(J3TelnetTextState) exceptForThoseInSet: [J3ByteSet byteSetWithBytes: J3TelnetInterpretAsCommand, -1]];
  [self assertState: C(J3TelnetTextState) givenByte: J3TelnetInterpretAsCommand producesState: C(J3TelnetIACState)];
}

- (void) testIACTransitionsThatInvalidateTelnet
{
  J3ByteSet *byteSet = [[J3TelnetState telnetCommandBytes] inverseSet];
  [byteSet addByte: J3TelnetBeginSubnegotiation];
  [byteSet addByte: J3TelnetEndSubnegotiation];
  NSData *bytes = [byteSet dataValue];
  for (unsigned i = 0; i < [bytes length]; ++i)
    [self assertByteInvalidatesTelnet: ((uint8_t *)[bytes bytes])[i]];
}

- (void) testIACTransitionsThatConfirmTelnet
{
  J3ByteSet *byteSet = [J3TelnetState telnetCommandBytes];
  [byteSet removeByte: J3TelnetBeginSubnegotiation];
  [byteSet removeByte: J3TelnetEndSubnegotiation];
  [byteSet removeByte: J3TelnetInterpretAsCommand];
  NSData *bytes = [byteSet dataValue];
  for (unsigned i = 0; i < [bytes length]; ++i)
    [self assertByteConfirmsTelnet: ((uint8_t *)[bytes bytes])[i]];
}
  
- (void) testIACTransitionsOnceConfirmed
{
  [engine confirmTelnet];
  [self assertState: C(J3TelnetIACState) givenByte: J3TelnetEndOfRecord producesState: C(J3TelnetTextState)];
  [self assertState: C(J3TelnetIACState) givenByte: J3TelnetNoOperation producesState: C(J3TelnetTextState)];
  [self assertState: C(J3TelnetIACState) givenByte: J3TelnetDataMark producesState: C(J3TelnetTextState)];
  [self assertState: C(J3TelnetIACState) givenByte: J3TelnetBreak producesState: C(J3TelnetTextState)];
  [self assertState: C(J3TelnetIACState) givenByte: J3TelnetInterruptProcess producesState: C(J3TelnetTextState)];
  [self assertState: C(J3TelnetIACState) givenByte: J3TelnetAbortOutput producesState: C(J3TelnetTextState)];
  [self assertState: C(J3TelnetIACState) givenByte: J3TelnetAreYouThere producesState: C(J3TelnetTextState)];
  [self assertState: C(J3TelnetIACState) givenByte: J3TelnetEraseCharacter producesState: C(J3TelnetTextState)];
  [self assertState: C(J3TelnetIACState) givenByte: J3TelnetEraseLine producesState: C(J3TelnetTextState)];
  [self assertState: C(J3TelnetIACState) givenByte: J3TelnetGoAhead producesState: C(J3TelnetTextState)];
  [self assertState: C(J3TelnetIACState) givenByte: J3TelnetDo producesState: C(J3TelnetDoState)];
  [self assertState: C(J3TelnetIACState) givenByte: J3TelnetDont producesState: C(J3TelnetDontState)];
  [self assertState: C(J3TelnetIACState) givenByte: J3TelnetWill producesState: C(J3TelnetWillState)];
  [self assertState: C(J3TelnetIACState) givenByte: J3TelnetWont producesState: C(J3TelnetWontState)];  
  [self assertState: C(J3TelnetIACState) givenByte: J3TelnetBeginSubnegotiation producesState: C(J3TelnetSubnegotiationOptionState)];
  [self assertState: C(J3TelnetIACState) givenByte: J3TelnetInterpretAsCommand producesState: C(J3TelnetTextState)];
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
  [self assertState: C(J3TelnetIACState) givenByte: J3TelnetInterpretAsCommand inputsByte: J3TelnetInterpretAsCommand];
}

- (void) testSubnegotiationStateTransitions
{
  [self assertState: C(J3TelnetSubnegotiationOptionState) givenAnyByteProducesState: C(J3TelnetSubnegotiationState) exceptForThoseInSet: [J3ByteSet byteSetWithBytes: J3TelnetInterpretAsCommand, J3TelnetOptionMCCP1, -1]];
  
  [self assertState: C(J3TelnetSubnegotiationState) givenAnyByteProducesState: C(J3TelnetSubnegotiationState) exceptForThoseInSet: [J3ByteSet byteSetWithBytes: J3TelnetInterpretAsCommand, -1]];
  [self assertState: C(J3TelnetSubnegotiationState) givenByte: J3TelnetInterpretAsCommand producesState: C(J3TelnetSubnegotiationIACState)];
  
  [self assertStateObject: [J3TelnetSubnegotiationIACState stateWithReturnState: C(J3TelnetSubnegotiationState)] givenAnyByteProducesState: C(J3TelnetSubnegotiationState) exceptForThoseInSet: [J3ByteSet byteSetWithBytes: J3TelnetEndSubnegotiation, -1]];
  [self assertStateObject: [J3TelnetSubnegotiationIACState stateWithReturnState: C(J3TelnetSubnegotiationState)] givenByte: J3TelnetEndSubnegotiation producesState: C(J3TelnetTextState)];
}

- (void) testMCCP1NegotiationStateTransitions
{
  [self assertState: C(J3TelnetSubnegotiationOptionState) givenByte: J3TelnetOptionMCCP1 producesState: C(J3TelnetMCCP1SubnegotiationState)];
  
  [self assertState: C(J3TelnetMCCP1SubnegotiationState) givenByte: J3TelnetWill producesState: C(J3TelnetSubnegotiationIACState)];
  
  [self assertStateObject: [J3TelnetSubnegotiationIACState stateWithReturnState: C(J3TelnetMCCP1SubnegotiationState)] givenAnyByteProducesState: C(J3TelnetMCCP1SubnegotiationState) exceptForThoseInSet: [J3ByteSet byteSetWithBytes: J3TelnetEndSubnegotiation, -1]];
  [self assertStateObject: [J3TelnetSubnegotiationIACState stateWithReturnState: C(J3TelnetMCCP1SubnegotiationState)] givenByte: J3TelnetEndSubnegotiation producesState: C(J3TelnetTextState)];
}

#pragma mark -
#pragma mark J3TelnetEngineDelegate

- (void) bufferInputByte: (uint8_t) byte
{
  lastByteInput = byte;
}

- (void) log: (NSString *) message arguments: (va_list) args
{
  return;
}

- (void) consumeReadBufferAsSubnegotiation
{
  return;
}

- (void) consumeReadBufferAsText
{
  return;
}

- (void) writeData: (NSData *) data
{
  [output setData: data];
}

@end

#pragma mark -

@implementation J3TelnetStateMachineTests (Private)

- (void) assertByteConfirmsTelnet: (uint8_t) byte;
{
  [self resetEngine];
  [[J3TelnetIACState state] parse: byte forEngine: engine];
  [self assertTrue: [engine telnetConfirmed] message: [NSString stringWithFormat: @"%d did not confirm telnet", byte]];
}

- (void) assertByteInvalidatesTelnet: (uint8_t) byte
{
  uint8_t bytes[] = {J3TelnetInterpretAsCommand, byte};
  [self assertState: C(J3TelnetIACState) givenByte: byte producesState: C(J3TelnetNotTelnetState)];
  [self assert: output equals: [NSData dataWithBytes: bytes length: 2]];  
}


- (void) assertState: (Class) stateClass givenAnyByteProducesState: (Class) nextStateClass
{
  [self assertState: stateClass givenAnyByteProducesState: nextStateClass exceptForThoseInSet: [J3ByteSet byteSet]];
}

- (void) assertState: (Class) stateClass givenAnyByteProducesState: (Class) nextStateClass exceptForThoseInSet: (J3ByteSet *) exclusions
{
  [self assertStateObject: [[[stateClass alloc] init] autorelease] givenAnyByteProducesState: nextStateClass exceptForThoseInSet: exclusions];
}

- (void) assertState: (Class) stateClass givenByte: (uint8_t) byte producesState: (Class) nextStateClass
{
  [self assertStateObject: [[[stateClass alloc] init] autorelease] givenByte: byte producesState: nextStateClass];
}

- (void) assertState: (Class) stateClass givenByte: (uint8_t) givenByte inputsByte: (uint8_t) inputsByte
{
  [self giveStateClass: stateClass byte: givenByte];
  [self assertInt: lastByteInput equals: inputsByte];
}

- (void) assertStateObject: (J3TelnetState *) state givenAnyByteProducesState: (Class) nextStateClass exceptForThoseInSet: (J3ByteSet *) exclusions
{
  NSData *bytes = [[exclusions inverseSet] dataValue];
  for (unsigned i = 0; i < [bytes length]; ++i)
    [self assertStateObject: state givenByte: ((uint8_t *)[bytes bytes])[i] producesState: nextStateClass];
}

- (void) assertStateObject: (J3TelnetState *) state givenByte: (uint8_t) byte producesState: (Class) nextStateClass
{
  J3TelnetState *nextState = [state parse: byte forEngine: engine];
  [self assert: [nextState class] equals: nextStateClass];  
}

- (void) giveStateClass: (Class) stateClass byte: (uint8_t) byte
{
  [[[[stateClass alloc] init] autorelease] parse: byte forEngine: engine];  
}

- (void) resetEngine
{
  [self at: &engine put: [J3TelnetEngine engine]];
  [engine setDelegate: self];
}

@end

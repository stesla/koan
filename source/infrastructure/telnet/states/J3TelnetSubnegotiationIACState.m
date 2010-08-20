//
// J3TelnetSubnegotiationIACState.m
//
// Copyright (c) 2010 3James Software.
//

#import "J3TelnetSubnegotiationIACState.h"

#import "J3TelnetConstants.h"
#import "J3TelnetProtocolHandler.h"
#import "J3TelnetSubnegotiationState.h"
#import "J3TelnetTextState.h"

@implementation J3TelnetSubnegotiationIACState

+ (id) stateWithReturnState: (Class) state
{
  return [[[self alloc] initWithReturnState: state] autorelease];
}

- (id) initWithReturnState: (Class) state
{
  if (!(self = [super init]))
    return nil;
  
  returnState = state;
  
  return self;
}

- (J3TelnetState *) parse: (uint8_t) byte
          forStateMachine: (J3TelnetStateMachine *) stateMachine
                 protocol: (NSObject <J3TelnetProtocolHandler> *) protocol
{
  switch (byte)
  {
    case J3TelnetEndSubnegotiation:
      [protocol handleBufferedSubnegotiation];
      return [J3TelnetTextState state];

    case J3TelnetInterpretAsCommand:
      [protocol bufferSubnegotiationByte: byte];
      return [returnState state];

    default:
      [protocol log: @"Telnet irregularity: IAC %u while in subnegotiation.", byte];
      return [returnState state];
  }
}

@end

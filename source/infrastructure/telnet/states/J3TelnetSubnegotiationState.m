//
// J3TelnetSubnegotiationState.m
//
// Copyright (c) 2010 3James Software.
//

#import "J3TelnetSubnegotiationState.h"

#import "J3TelnetConstants.h"
#import "J3TelnetProtocolHandler.h"
#import "J3TelnetSubnegotiationIACState.h"

@implementation J3TelnetSubnegotiationState

- (J3TelnetState *) parse: (uint8_t) byte
          forStateMachine: (J3TelnetStateMachine *) stateMachine
                 protocol: (NSObject <J3TelnetProtocolHandler> *) protocol
{
  switch (byte)
  {
    case J3TelnetInterpretAsCommand:
      return [J3TelnetSubnegotiationIACState stateWithReturnState: [J3TelnetSubnegotiationState class]];
      
    default:
      [protocol bufferSubnegotiationByte: byte];
      return self;
  }
}

@end

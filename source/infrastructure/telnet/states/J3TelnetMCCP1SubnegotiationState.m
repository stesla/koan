//
// J3TelnetMCCP1SubnegotiationState.m
//
// Copyright (c) 2010 3James Software.
//

#import "J3TelnetConstants.h"
#import "J3TelnetProtocolHandler.h"
#import "J3TelnetMCCP1SubnegotiationState.h"
#import "J3TelnetSubnegotiationIACState.h"

@implementation J3TelnetMCCP1SubnegotiationState

- (J3TelnetState *) parse: (uint8_t) byte
          forStateMachine: (J3TelnetStateMachine *) stateMachine
                 protocol: (NSObject <J3TelnetProtocolHandler> *) protocol
{
  switch (byte)
  {
    case J3TelnetWill:
      return [J3TelnetSubnegotiationIACState stateWithReturnState: [J3TelnetMCCP1SubnegotiationState class]];
  
    case J3TelnetInterpretAsCommand:
      [protocol log: @"Telnet irregularity: Received IAC while subnegotiating %@ option; expected WILL.", [protocol optionNameForByte: J3TelnetOptionMCCP1]];
      return [J3TelnetSubnegotiationIACState stateWithReturnState: [J3TelnetMCCP1SubnegotiationState class]];

    default:
      [protocol bufferTextByte: byte];
      return self;
  }
}
@end

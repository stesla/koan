//
// J3TelnetSubnegotiationOptionState.m
//
// Copyright (c) 2010 3James Software.
//

#import "J3TelnetSubnegotiationOptionState.h"

#import "J3TelnetConstants.h"
#import "J3TelnetMCCP1SubnegotiationState.h"
#import "J3TelnetProtocolHandler.h"
#import "J3TelnetSubnegotiationIACState.h"
#import "J3TelnetSubnegotiationState.h"

@implementation J3TelnetSubnegotiationOptionState

- (J3TelnetState *) parse: (uint8_t) byte
          forStateMachine: (J3TelnetStateMachine *) stateMachine
                 protocol: (NSObject <J3TelnetProtocolHandler> *) protocol
{
  switch (byte)
  {
    case J3TelnetInterpretAsCommand:
      [protocol log: @"Telnet irregularity: IAC received immediately after IAC SB."];
      return [J3TelnetSubnegotiationIACState state];
      
    case J3TelnetOptionMCCP1:
      [protocol bufferSubnegotiationByte: byte];
      return [J3TelnetMCCP1SubnegotiationState state];
      
    default:
      [protocol bufferSubnegotiationByte: byte];
      return [J3TelnetSubnegotiationState state];
  }
}

@end

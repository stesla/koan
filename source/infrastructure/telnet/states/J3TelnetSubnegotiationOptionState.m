//
// J3TelnetSubnegotiationOptionState.m
//
// Copyright (c) 2010 3James Software.
//

#import "J3TelnetSubnegotiationOptionState.h"

#import "J3TelnetConstants.h"
#import "J3TelnetEngine.h"
#import "J3TelnetMCCP1SubnegotiationState.h"
#import "J3TelnetSubnegotiationIACState.h"
#import "J3TelnetSubnegotiationState.h"

@implementation J3TelnetSubnegotiationOptionState

- (J3TelnetState *) parse: (uint8_t) byte forEngine: (J3TelnetEngine *) engine
{
  switch (byte)
  {
    case J3TelnetInterpretAsCommand:
      [engine log: @"Telnet irregularity: IAC received immediately after IAC SB."];
      return [J3TelnetSubnegotiationIACState state];
      
    case J3TelnetOptionMCCP1:
      [engine bufferTextInputByte: byte];
      return [J3TelnetMCCP1SubnegotiationState state];
      
    default:
      [engine bufferTextInputByte: byte];
      return [J3TelnetSubnegotiationState state];
  }
}

@end

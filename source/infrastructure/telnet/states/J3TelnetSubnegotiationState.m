//
// J3TelnetSubnegotiationState.m
//
// Copyright (c) 2007 3James Software.
//

#import "J3TelnetSubnegotiationState.h"
#import "J3TelnetSubnegotiationIACState.h"
#import "J3TelnetConstants.h"
#import "J3TelnetOptionMCCP1State.h"

@implementation J3TelnetSubnegotiationState

- (J3TelnetState *) parse: (uint8_t) byte forEngine: (J3TelnetEngine *) engine
{
  switch (byte)
  {
    case J3TelnetInterpretAsCommand:
      return [J3TelnetSubnegotiationIACState state];
      
    case J3TelnetOptionMCCP1:
      return [J3TelnetOptionMCCP1State state];
      
    default:
      return self;
  }
}

@end

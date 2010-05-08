//
// J3TelnetSubnegotiationState.m
//
// Copyright (c) 2010 3James Software.
//

#import "J3TelnetSubnegotiationState.h"

#import "J3TelnetConstants.h"
#import "J3TelnetEngine.h"
#import "J3TelnetSubnegotiationIACState.h"

@implementation J3TelnetSubnegotiationState

- (J3TelnetState *) parse: (uint8_t) byte forEngine: (J3TelnetEngine *) engine
{
  switch (byte)
  {
    case J3TelnetInterpretAsCommand:
      return [J3TelnetSubnegotiationIACState stateWithReturnState: [J3TelnetSubnegotiationState class]];
      
    default:
      [engine bufferTextInputByte: byte];
      return self;
  }
}

@end

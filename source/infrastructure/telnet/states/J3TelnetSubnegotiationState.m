//
//  J3TelnetSubnegotiationState.m
//  Koan
//
//  Created by Samuel Tesla on 4/5/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "J3TelnetSubnegotiationState.h"
#import "J3TelnetSubnegotiationIACState.h"
#import "J3TelnetConstants.h"
#import "J3TelnetOptionMCCP1State.h"

@implementation J3TelnetSubnegotiationState

- (J3TelnetState *) parse: (uint8_t) byte forParser: (J3TelnetEngine *) parser
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

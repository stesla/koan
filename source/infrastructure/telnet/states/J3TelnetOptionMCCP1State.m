//
//  J3TelnetOptionMCCP1State.m
//  Koan
//
//  Created by Samuel Tesla on 4/5/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "J3TelnetConstants.h"
#import "J3TelnetOptionMCCP1State.h"
#import "J3TelnetSubnegotiationIACState.h"

@implementation J3TelnetOptionMCCP1State

- (J3TelnetState *) parse: (uint8_t) byte forParser: (J3TelnetEngine *) parser
{
  if (byte == J3TelnetWill)
    return [J3TelnetSubnegotiationIACState state];
  else
    return self;
}
@end

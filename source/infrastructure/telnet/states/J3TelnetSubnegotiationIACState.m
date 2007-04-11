//
//  J3TelnetSubnegotiationIACState.m
//  Koan
//
//  Created by Samuel Tesla on 4/5/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "J3TelnetConstants.h"
#import "J3TelnetSubnegotiationIACState.h"
#import "J3TelnetSubnegotiationState.h"
#import "J3TelnetTextState.h"


@implementation J3TelnetSubnegotiationIACState

- (J3TelnetState *) parse: (uint8_t) byte forEngine: (J3TelnetEngine *) engine
{
  if (byte == J3TelnetEndSubnegotiation)
    return [J3TelnetTextState state];
  else
    return [J3TelnetSubnegotiationState state];
}

@end

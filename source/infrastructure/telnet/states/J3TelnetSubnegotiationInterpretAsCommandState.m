//
//  J3TelnetSubnegotiationInterpretAsCommandState.m
//  Koan
//
//  Created by Samuel Tesla on 4/5/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "J3TelnetConstants.h"
#import "J3TelnetSubnegotiationInterpretAsCommandState.h"
#import "J3TelnetSubnegotiationState.h"
#import "J3TelnetTextState.h"


@implementation J3TelnetSubnegotiationInterpretAsCommandState

- (J3TelnetState *) parse: (uint8_t) byte forParser: (J3TelnetEngine *) parser
{
  if (byte == J3TelnetEndSubnegotiation)
    return [J3TelnetTextState state];
  else
    return [J3TelnetSubnegotiationState state];
}

@end

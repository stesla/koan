//
// J3TelnetSubnegotiationIACState.h
//
// Copyright (c) 2010 3James Software.
//

#import "J3TelnetState.h"

@interface J3TelnetSubnegotiationIACState : J3TelnetState
{
  Class returnState;
}

+ (id) stateWithReturnState: (Class) state;

- (id) initWithReturnState: (Class) state;

@end

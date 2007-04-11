//
// J3TelnetIACState.m
//
// Copyright (c) 2007 3James Software.
//

#import "J3TelnetConstants.h"
#import "J3TelnetDoState.h"
#import "J3TelnetDontState.h"
#import "J3TelnetIACState.h"
#import "J3TelnetEngine.h"
#import "J3TelnetState.h"
#import "J3TelnetSubnegotiationState.h"
#import "J3TelnetTextState.h"
#import "J3TelnetWillState.h"
#import "J3TelnetWontState.h"

@implementation J3TelnetIACState

- (J3TelnetState *) parse: (uint8_t) byte forParser: (J3TelnetEngine *) parser
{
  switch (byte)
  {
    case J3TelnetDo:
      return [J3TelnetDoState state];
      
    case J3TelnetDont:
      return [J3TelnetDontState state];
    
    case J3TelnetWill:
      return [J3TelnetWillState state];
    
    case J3TelnetWont:
      return [J3TelnetWontState state];

    case J3TelnetInterpretAsCommand:
      [parser bufferInputByte: J3TelnetInterpretAsCommand];
      return [J3TelnetTextState state];
      
    case J3TelnetBeginSubnegotiation:
      return [J3TelnetSubnegotiationState state];
        
    default:
      return [J3TelnetTextState state];
  }
}

@end

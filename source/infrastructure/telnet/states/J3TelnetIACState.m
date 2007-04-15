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

- (J3TelnetState *) parse: (uint8_t) byte forEngine: (J3TelnetEngine *) engine
{
  switch (byte)
  {
    // TODO: handle these valid commands individually.
    case J3TelnetEndOfRecord:
    case J3TelnetNoOperation:
    case J3TelnetDataMark:
    case J3TelnetBreak:
    case J3TelnetInterruptProcess:
    case J3TelnetAbortOutput:
    case J3TelnetAreYouThere:
    case J3TelnetEraseCharacter:
    case J3TelnetEraseLine:
    case J3TelnetGoAhead:
      // TODO: these complete a valid telnet command.
      return [J3TelnetTextState state];
      
    case J3TelnetBeginSubnegotiation:
      // TODO: subnegotiations are valid telnet if and only if we've negotiated
      // to use the corresponding option.
      return [J3TelnetSubnegotiationState state];
      
    case J3TelnetWill:
      // TODO: for all the option state modifiers, whatever follows is valid,
      // since we want to allow for unsupported options that we don't know about
      // without bailing on telnet.
      return [J3TelnetWillState state];
      
    case J3TelnetWont:
      return [J3TelnetWontState state];
      
    case J3TelnetDo:
      return [J3TelnetDoState state];
      
    case J3TelnetDont:
      return [J3TelnetDontState state];
      
    case J3TelnetInterpretAsCommand:
      [engine bufferInputByte: J3TelnetInterpretAsCommand];
      return [J3TelnetTextState state];
      
    case J3TelnetEndSubnegotiation:
    default:
      // TODO: this is invalid telnet.
      return [J3TelnetTextState state];
  }
}

@end

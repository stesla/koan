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
#import "J3TelnetNotTelnetState.h"
#import "J3TelnetState.h"
#import "J3TelnetSubnegotiationState.h"
#import "J3TelnetTextState.h"
#import "J3TelnetWillState.h"
#import "J3TelnetWontState.h"

@interface J3TelnetIACState (Private)

- (J3TelnetState *) notTelnetFromByte: (uint8_t) byte forEngine: (J3TelnetEngine *) engine;

@end

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
      [engine confirmTelnet];
      return [J3TelnetTextState state];
           
    case J3TelnetWill:
      [engine confirmTelnet];
      return [J3TelnetWillState state];
      
    case J3TelnetWont:
      [engine confirmTelnet];
      return [J3TelnetWontState state];
      
    case J3TelnetDo:
      [engine confirmTelnet];
      return [J3TelnetDoState state];
      
    case J3TelnetDont:
      [engine confirmTelnet];
      return [J3TelnetDontState state];
      
    case J3TelnetInterpretAsCommand:
      [[engine delegate] bufferInputByte: J3TelnetInterpretAsCommand];
      return [J3TelnetTextState state];

    case J3TelnetBeginSubnegotiation:
      if ([engine telnetConfirmed])
        return [J3TelnetSubnegotiationState state];
    case J3TelnetEndSubnegotiation:
    default:
      return [self notTelnetFromByte: byte forEngine: engine];
  }
}

@end

#pragma mark -

@implementation J3TelnetIACState (Private)

- (J3TelnetState *) notTelnetFromByte: (uint8_t) byte forEngine: (J3TelnetEngine *) engine
{
  uint8_t bytes[] = {J3TelnetInterpretAsCommand, byte};
  [[engine delegate] writeData: [NSData dataWithBytes: bytes length: 2]];
  return [J3TelnetNotTelnetState state];
}

@end


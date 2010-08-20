//
// J3TelnetIACState.m
//
// Copyright (c) 2010 3James Software.
//

#import "J3TelnetConstants.h"
#import "J3TelnetDoState.h"
#import "J3TelnetDontState.h"
#import "J3TelnetIACState.h"
#import "J3TelnetNotTelnetState.h"
#import "J3TelnetProtocolHandler.h"
#import "J3TelnetState.h"
#import "J3TelnetSubnegotiationOptionState.h"
#import "J3TelnetTextState.h"
#import "J3TelnetWillState.h"
#import "J3TelnetWontState.h"

@interface J3TelnetIACState (Private)

- (J3TelnetState *) notTelnetFromByte: (uint8_t) byte
                      forStateMachine: (J3TelnetStateMachine *) stateMachine
                             protocol: (NSObject <J3TelnetProtocolHandler> *) protocol;

@end

#pragma mark -

@implementation J3TelnetIACState

- (J3TelnetState *) parse: (uint8_t) byte
          forStateMachine: (J3TelnetStateMachine *) stateMachine
                 protocol: (NSObject <J3TelnetProtocolHandler> *) protocol
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
      [stateMachine confirmTelnet];
      return [J3TelnetTextState state];
           
    case J3TelnetWill:
      [stateMachine confirmTelnet];
      return [J3TelnetWillState state];
      
    case J3TelnetWont:
      [stateMachine confirmTelnet];
      return [J3TelnetWontState state];
      
    case J3TelnetDo:
      [stateMachine confirmTelnet];
      return [J3TelnetDoState state];
      
    case J3TelnetDont:
      [stateMachine confirmTelnet];
      return [J3TelnetDontState state];
      
    case J3TelnetInterpretAsCommand:
      [protocol bufferTextByte: J3TelnetInterpretAsCommand];
      return [J3TelnetTextState state];

    case J3TelnetBeginSubnegotiation:
      if (!stateMachine.telnetConfirmed)
      {
        [protocol log: @"Not telnet: IAC SB without receiving earlier telnet sequences."];
        return [self notTelnetFromByte: byte forStateMachine: stateMachine protocol: protocol];
      }
      
      return [J3TelnetSubnegotiationOptionState state];
      
    case J3TelnetEndSubnegotiation:
    default:
      if (!stateMachine.telnetConfirmed)
      {
        [protocol log: @"Not telnet: IAC SE without receiving earlier telnet sequences."];
        return [self notTelnetFromByte: byte forStateMachine: stateMachine protocol: protocol];
      }
      
      [protocol log: @"Telnet irregularity: IAC SE while not in subnegotiation."];
      return [J3TelnetTextState state];
  }
}

@end

#pragma mark -

@implementation J3TelnetIACState (Private)

- (J3TelnetState *) notTelnetFromByte: (uint8_t) byte
                      forStateMachine: (J3TelnetStateMachine *) stateMachine
                             protocol: (NSObject <J3TelnetProtocolHandler> *) protocol
{
  [protocol bufferTextByte: J3TelnetInterpretAsCommand];
  [protocol bufferTextByte: byte];
  return [J3TelnetNotTelnetState state];
}

@end


//
// J3TelnetDontState.m
//
// Copyright (c) 2010 3James Software.
//

#import "J3TelnetConstants.h"
#import "J3TelnetDontState.h"
#import "J3TelnetProtocolHandler.h"
#import "J3TelnetTextState.h"

@implementation J3TelnetDontState

- (J3TelnetState *) parse: (uint8_t) byte
          forStateMachine: (J3TelnetStateMachine *) stateMachine
                 protocol: (NSObject <J3TelnetProtocolHandler> *) protocol
{
  [protocol log: @"Received: IAC DONT %@.", [protocol optionNameForByte: byte]];
  [protocol receivedDont: byte];
  return [J3TelnetTextState state];
}

@end

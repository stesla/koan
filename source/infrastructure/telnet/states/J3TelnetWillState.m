//
// J3TelnetWillState.m
//
// Copyright (c) 2010 3James Software.
//

#import "J3TelnetConstants.h"
#import "J3TelnetProtocolHandler.h"
#import "J3TelnetTextState.h"
#import "J3TelnetWillState.h"

@implementation J3TelnetWillState

- (J3TelnetState *) parse: (uint8_t) byte
          forStateMachine: (J3TelnetStateMachine *) stateMachine
                 protocol: (NSObject <J3TelnetProtocolHandler> *) protocol
{
  [protocol log: @"Received: IAC WILL %@.", [protocol optionNameForByte: byte]];
  [protocol receivedWill: byte];
  return [J3TelnetTextState state];
}

@end

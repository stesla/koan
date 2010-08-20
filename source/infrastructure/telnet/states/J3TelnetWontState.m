//
// J3TelnetWontState.m
//
// Copyright (c) 2010 3James Software.
//

#import "J3TelnetConstants.h"
#import "J3TelnetProtocolHandler.h"
#import "J3TelnetTextState.h"
#import "J3TelnetWontState.h"

@implementation J3TelnetWontState

- (J3TelnetState *) parse: (uint8_t) byte
          forStateMachine: (J3TelnetStateMachine *) stateMachine
                 protocol: (NSObject <J3TelnetProtocolHandler> *) protocol
{
  [protocol log: @"Received: IAC WONT %@.", [protocol optionNameForByte: byte]];
  [protocol receivedWont: byte];
  return [J3TelnetTextState state];
}

@end

//
// J3TelnetDoState.m
//
// Copyright (c) 2010 3James Software.
//

#import "J3TelnetConstants.h"
#import "J3TelnetDoState.h"
#import "J3TelnetProtocolHandler.h"
#import "J3TelnetTextState.h"

@implementation J3TelnetDoState

- (J3TelnetState *) parse: (uint8_t) byte
          forStateMachine: (J3TelnetStateMachine *) stateMachine
                 protocol: (NSObject <J3TelnetProtocolHandler> *) protocol
{
  [protocol log: @"Received: IAC DO %@.", [protocol optionNameForByte: byte]];
  [protocol receivedDo: byte];
  return [J3TelnetTextState state];
}

@end

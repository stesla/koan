//
// J3TelnetTextState.m
//
// Copyright (c) 2010 3James Software.
//

#import "J3TelnetConstants.h"
#import "J3TelnetIACState.h"
#import "J3TelnetProtocolHandler.h"
#import "J3TelnetTextState.h"

@implementation J3TelnetTextState

- (J3TelnetState *) parse: (uint8_t) byte
          forStateMachine: (J3TelnetStateMachine *) stateMachine
                 protocol: (NSObject <J3TelnetProtocolHandler> *) protocol
{
  if (byte == J3TelnetInterpretAsCommand)
    return [J3TelnetIACState state];
  else
  {
    [protocol bufferTextByte: byte];
    return self;
  }
}

@end

//
// J3TelnetNotTelnetState.m
//
// Copyright (c) 2010 3James Software.
//

#import "J3TelnetNotTelnetState.h"
#import "J3TelnetProtocolHandler.h"

@implementation J3TelnetNotTelnetState

- (J3TelnetState *) parse: (uint8_t) byte
          forStateMachine: (J3TelnetStateMachine *) stateMachine
                 protocol: (NSObject <J3TelnetProtocolHandler> *) protocol
{
  // If we've decided we're not dealing with Telnet, just pass everything on as text, forever.
  
  [protocol bufferTextByte: byte];
  return self;
}

@end

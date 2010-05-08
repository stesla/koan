//
// J3TelnetNotTelnetState.m
//
// Copyright (c) 2010 3James Software.
//

#import "J3TelnetNotTelnetState.h"
#import "J3TelnetEngine.h"

@implementation J3TelnetNotTelnetState

- (J3TelnetState *) parse: (uint8_t) byte forEngine: (J3TelnetEngine *) engine;
{
  // If we've decided we're not dealing with Telnet, just pass everything on as text, forever.
  
  [engine bufferTextInputByte: byte];
  return self;
}

@end

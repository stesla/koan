//
// J3TelnetDontState.m
//
// Copyright (c) 2007 3James Software.
//

#import "J3TelnetConstants.h"
#import "J3TelnetDontState.h"
#import "J3TelnetEngine.h"
#import "J3TelnetTextState.h"

@implementation J3TelnetDontState

- (J3TelnetState *) parse: (uint8_t) byte forEngine: (J3TelnetEngine *) engine
{
  [engine log: @"Received: IAC DONT %@", [engine optionNameForByte: byte]];
  [engine receivedDont: byte];
  return [J3TelnetTextState state];
}

@end

//
// J3TelnetWillState.m
//
// Copyright (c) 2007 3James Software.
//

#import "J3TelnetConstants.h"
#import "J3TelnetWillState.h"
#import "J3TelnetEngine.h"
#import "J3TelnetTextState.h"

@implementation J3TelnetWillState

- (J3TelnetState *) parse: (uint8_t) byte forEngine: (J3TelnetEngine *) engine
{
  [engine log: @"Received: IAC WILL %@", [engine optionNameForByte: byte]];
  [engine receivedWill: byte];
  return [J3TelnetTextState state];
}

@end

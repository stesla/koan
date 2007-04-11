//
// J3TelnetWontState.m
//
// Copyright (c) 2007 3James Software.
//

#import "J3TelnetConstants.h"
#import "J3TelnetEngine.h"
#import "J3TelnetTextState.h"
#import "J3TelnetWontState.h"

@implementation J3TelnetWontState

- (J3TelnetState *) parse: (uint8_t) byte forEngine: (J3TelnetEngine *) engine
{
  [engine log: @"Received: IAC WONT %@", [engine optionNameForByte: byte]];
  [engine receivedWont: byte];
  return [J3TelnetTextState state];
}

@end

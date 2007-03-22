//
// J3TelnetWillState.m
//
// Copyright (c) 2005 3James Software
//

#import "J3TelnetConstants.h"
#import "J3TelnetWillState.h"
#import "J3TelnetEngine.h"
#import "J3TelnetTextState.h"

@implementation J3TelnetWillState

- (J3TelnetState *) parse: (uint8_t) byte forParser: (J3TelnetEngine *) parser
{
  NSLog (@"Received: IAC WILL %@", [parser optionNameForByte: byte]);
  [parser dont: byte];
  return [J3TelnetTextState state];
}

@end

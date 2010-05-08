//
// J3TelnetDoState.m
//
// Copyright (c) 2010 3James Software.
//

#import "J3TelnetConstants.h"
#import "J3TelnetDoState.h"
#import "J3TelnetEngine.h"
#import "J3TelnetTextState.h"

@implementation J3TelnetDoState

- (J3TelnetState *) parse: (uint8_t) byte forEngine: (J3TelnetEngine *) engine
{
  [engine log: @"Received: IAC DO %@.", [engine optionNameForByte: byte]];
  [engine receivedDo: byte];
  return [J3TelnetTextState state];
}

@end

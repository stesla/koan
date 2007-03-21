//
// J3TelnetWontState.m
//
// Copyright (c) 2005 3James Software
//

#import "J3TelnetConstants.h"
#import "J3TelnetEngine.h"
#import "J3TelnetTextState.h"
#import "J3TelnetWontState.h"

@implementation J3TelnetWontState

- (J3TelnetState *) parse:(uint8_t)byte forParser:(J3TelnetEngine *)parser
{
  NSLog (@"Received: IAC WONT %@", [parser optionNameForByte:byte]);
  return [J3TelnetTextState state];
}

@end

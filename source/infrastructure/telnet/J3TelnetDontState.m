//
// J3TelnetDontState.m
//
// Copyright (c) 2005 3James Software
//

#import "J3TelnetConstants.h"
#import "J3TelnetDontState.h"
#import "J3TelnetEngine.h"
#import "J3TelnetTextState.h"

@implementation J3TelnetDontState

- (J3TelnetState *) parse:(uint8_t)byte forParser:(J3TelnetEngine *)parser
{
  NSLog (@"Received: IAC DONT %@", [parser optionNameForByte:byte]);
  return [J3TelnetTextState state];
}

@end

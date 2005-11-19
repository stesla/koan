//
// J3TelnetDontState.m
//
// Copyright (c) 2005 3James Software
//

#import "J3TelnetConstants.h"
#import "J3TelnetDontState.h"
#import "J3TelnetParser.h"
#import "J3TelnetTextState.h"

@implementation J3TelnetDontState

- (J3TelnetState *) parse:(uint8_t)byte forParser:(J3TelnetParser *)parser
{
  return [J3TelnetTextState state];
}

@end

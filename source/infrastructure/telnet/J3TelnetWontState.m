//
// J3TelnetWontState.m
//
// Copyright (c) 2005 3James Software
//

#import "J3TelnetConstants.h"
#import "J3TelnetParser.h"
#import "J3TelnetTextState.h"
#import "J3TelnetWontState.h"

@implementation J3TelnetWontState

- (J3TelnetState *) parse:(uint8_t)byte forParser:(J3TelnetParser *)parser
{
  [parser bufferOutputByte:J3TelnetDont];
  return [J3TelnetTextState state];
}

@end

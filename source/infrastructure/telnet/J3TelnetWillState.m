//
// J3TelnetWillState.m
//
// Copyright (c) 2005 3James Software
//

#import "J3TelnetConstants.h"
#import "J3TelnetWillState.h"
#import "J3TelnetParser.h"
#import "J3TelnetTextState.h"

@implementation J3TelnetWillState

- (J3TelnetState *) parse:(uint8_t)byte forParser:(J3TelnetParser *)parser
{
  [parser bufferOutputByte:J3TelnetInterpretAsCommand];
  [parser bufferOutputByte:J3TelnetDont];
  return [J3TelnetTextState state];
}

@end

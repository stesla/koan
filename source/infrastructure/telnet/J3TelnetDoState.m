//
// J3TelnetDoState.m
//
// Copyright (c) 2005 3James Software
//

#import "J3TelnetConstants.h"
#import "J3TelnetDoState.h"
#import "J3TelnetParser.h"
#import "J3TelnetTextState.h"

@implementation J3TelnetDoState

- (J3TelnetState *) parse:(uint8_t)byte forParser:(J3TelnetParser *)parser
{
  [parser bufferOutputByte:J3TelnetInterpretAsCommand];
  [parser bufferOutputByte:J3TelnetWont];
  [parser bufferOutputByte:byte];
  return [J3TelnetTextState state];
}

@end

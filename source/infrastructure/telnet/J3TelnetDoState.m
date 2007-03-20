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
  NSLog (@"Received: IAC DO %@", [parser optionNameForByte:byte]);
  [parser wont:byte];
  return [J3TelnetTextState state];
}

@end

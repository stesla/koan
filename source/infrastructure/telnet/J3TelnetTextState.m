//
// J3TelnetTextState.m
//
// Copyright (c) 2007 3James Software. All rights reserved.
//

#import "J3TelnetInterpretAsCommandState.h"
#import "J3TelnetEngine.h"
#import "J3TelnetTextState.h"
#import "J3TelnetConstants.h"

@implementation J3TelnetTextState

- (J3TelnetState *) parse: (uint8_t) byte forParser: (J3TelnetEngine *) parser
{
  if (byte == J3TelnetInterpretAsCommand)
    return [J3TelnetInterpretAsCommandState state];
  else
  {
    [parser bufferInputByte: byte];
    return self;
  }
}

@end

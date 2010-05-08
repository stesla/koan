//
// J3TelnetTextState.m
//
// Copyright (c) 2010 3James Software.
//

#import "J3TelnetIACState.h"
#import "J3TelnetEngine.h"
#import "J3TelnetTextState.h"
#import "J3TelnetConstants.h"

@implementation J3TelnetTextState

- (J3TelnetState *) parse: (uint8_t) byte forEngine: (J3TelnetEngine *) engine
{
  if (byte == J3TelnetInterpretAsCommand)
    return [J3TelnetIACState state];
  else
  {
    [engine bufferTextInputByte: byte];
    return self;
  }
}

@end

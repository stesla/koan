//
//  J3TelnetTextState.m
//  NewTelnet
//
//  Created by Samuel Tesla on 11/9/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "J3TelnetInterpretAsCommandState.h"
#import "J3TelnetParser.h"
#import "J3TelnetTextState.h"
#import "J3TelnetConstants.h"

@implementation J3TelnetTextState
- (J3TelnetState *) parse:(uint8_t)byte forParser:(J3TelnetParser *)parser;
{
  if (byte == J3TelnetInterpretAsCommand)
    return [J3TelnetInterpretAsCommandState state];
  else
  {
    [parser bufferInputByte:byte];
    return self;
  }
}
@end

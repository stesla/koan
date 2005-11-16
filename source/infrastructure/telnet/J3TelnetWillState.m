//
//  J3TelnetWillState.m
//  NewTelnet
//
//  Created by Samuel Tesla on 11/9/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "J3TelnetConstants.h"
#import "J3TelnetWillState.h"
#import "J3TelnetParser.h"
#import "J3TelnetTextState.h"

@implementation J3TelnetWillState
- (J3TelnetState *) parse:(uint8_t)byte forParser:(J3TelnetParser *)parser;
{
  [parser bufferOutputByte:J3TelnetDont];
  return [J3TelnetTextState state];
}
@end

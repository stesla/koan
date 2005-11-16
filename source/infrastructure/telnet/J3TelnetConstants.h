//
//  J3TelnetConstants.h
//  NewTelnet
//
//  Created by Samuel Tesla on 11/9/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

enum J3TelnetCommands
{
  J3TelnetEndSubnegotiation = 240,
  J3TelnetNoOperation = 241,
  J3TelnetDataMark = 242,
  J3TelnetBreak = 243,
  J3TelnetInterruptProcess = 244,
  J3TelnetAbortOutput = 245,
  J3TelnetAreYouThere = 246,
  J3TelnetEraseCharacter = 247,
  J3TelnetEraseLine = 248,
  J3TelnetGoAhead = 249,
  J3TelnetBeginSubnegotiation = 250,
  J3TelnetWill = 251,
  J3TelnetWont = 252,
  J3TelnetDo = 253,
  J3TelnetDont = 254,
  J3TelnetInterpretAsCommand = 255,
};
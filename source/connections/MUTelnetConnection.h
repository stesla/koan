//
//  MUTelnetConnection.h
//  Koan
//
//  Created by Samuel on 8/12/04.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "MUSocketConnection.h"

enum MUTelnetCommands
{
  TEL_SE  = 240,
  TEL_NOP,
  TEL_DM,
  TEL_BRK,
  TEL_IP,
  TEL_AO,
  TEL_AYT,
  TEL_EC,
  TEL_EL,
  TEL_GA,
  TEL_SB,
  TEL_WILL,
  TEL_WONT,
  TEL_DO,
  TEL_DONT,
  TEL_IAC
};

@interface MUTelnetConnection : NSObject
{
  MUSocketConnection *socket;
}

@end

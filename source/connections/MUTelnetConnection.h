//
// MUTelnetConnection.h
//
// Copyright (C) 2004 Tyler Berry and Samuel Tesla
//
// Koan is free software; you can redistribute it and/or modify it under the
// terms of the GNU General Public License as published by the Free Software
// Foundation; either version 2 of the License, or (at your option) any later
// version.
//
// Koan is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// Koan; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
// Suite 330, Boston, MA 02111-1307 USA
//

#import <Cocoa/Cocoa.h>

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

#define MUTelnetBufferMax 1024

@interface MUTelnetConnection : NSObject
{
  NSMutableData *_data;
}

- (NSString *) read;

// NSStream delegate
- (void) stream:(NSStream *)stream handleEvent:(NSStreamEvent)event;

@end
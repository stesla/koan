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
  TEL_SE   = 240,
  TEL_NOP  = 241,
  TEL_DM   = 242,
  TEL_BRK  = 243,
  TEL_IP   = 244,
  TEL_AO   = 245,
  TEL_AYT  = 246,
  TEL_EC   = 247,
  TEL_EL   = 248,
  TEL_GA   = 249,
  TEL_SB   = 250,
  TEL_WILL = 251,
  TEL_WONT = 252,
  TEL_DO   = 253,
  TEL_DONT = 254,
  TEL_IAC  = 255,
  TEL_NONE = 256
};

#define MUTelnetBufferMax 1024

@interface MUTelnetConnection : NSObject
{
  NSInputStream *_input;
  NSMutableData *_readBuffer;
  NSOutputStream *_output;
  NSMutableData *_writeBuffer;
  BOOL _canWrite;
  BOOL _isConnected;
  BOOL _isInCommand;
  int _commandChar;
  id _delegate;
}

// Designated initializer
- (id) initWithInputStream:(NSInputStream *)input  
              outputStream:(NSOutputStream *)output;

- (id) initWithHostName:(NSString *)hostName 
             onPort:(int)port;

// Getters
- (id) delegate;
- (NSInputStream *) input;
- (NSOutputStream *) output;

// Setters
- (void) setDelegate:(id)delegate;
- (void) setInput:(NSInputStream *)input;
- (void) setOutput:(NSOutputStream *)output;

// Connecting
- (void) open;
- (void) close;

// State Flags
- (BOOL) isConnected;
- (BOOL) isInCommand;

// IO
- (NSString *) read;
- (void) writeData:(NSData *)data;
- (void) writeString:(NSString *)string;

// NSStream delegate
- (void) stream:(NSStream *)stream handleEvent:(NSStreamEvent)event;
@end

// Delegate Methods
@interface NSObject (MUTelnetConnectionDelegate)
- (void) telnetConnectionDidEnd:(MUTelnetConnection *)telnet;
- (void) telnetDidReadLine:(MUTelnetConnection *)telnet;
- (void) telnet:(MUTelnetConnection *)telnet statusMessage:(NSString *)message;
@end

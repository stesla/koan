//
//  MUSocketConnection.h
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

#include <arpa/inet.h>
#include <netdb.h>
#include <netinet/in.h>
#include <stdio.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/uio.h>
#include <unistd.h>

@interface MUSocketConnection : NSObject
{
  int         _bufferSize;
  id          _delegate;
  NSString*   _host;
  short       _port;
  int         _socket;
}

+ (id) socketWithHost:(NSString *)host port:(short)port;

- (id) initWithHost:(NSString *)host port:(short)port;

- (int) bufferSize;
- (void) close;
- (id) delegate;
- (NSString *) host;
- (BOOL) isConnected;
- (short) port;
- (BOOL) open;
- (void) setBufferSize:(int)size;
- (void) setDelegate:(id)delegate;
- (void) setHost:(NSString *)host;
- (void) setPort:(short)port;
- (int) writeData:(NSData *)data;
@end

@interface NSObject (MUSocketConnectionDelegate)
- (void) socket:(MUSocketConnection *)socket didReadData:(NSData *)data;
@end

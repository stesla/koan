//
//  J3Socket.h
//  NewTelnet
//
//  Created by Samuel Tesla on 11/10/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <netinet/in.h>

NSString * J3SocketError;

@interface J3Socket : NSObject
{
  id delegate;
  NSString * hostname;
  int port;
  int socketfd;
  struct hostent * server;
	struct sockaddr_in server_addr;
  BOOL hasDataAvailable;
  BOOL hasError;
  BOOL hasSpaceAvailable;
}

+ (id) socketWithHostname:(NSString *)hostname port:(int)port;
- (id) initWithHostname:(NSString *)hostname port:(int)port;

- (void) setDelegate:(id)object;

- (void) open;
- (void) close;

- (BOOL) hasDataAvailable;
- (BOOL) hasError;
- (BOOL) hasSpaceAvailable;
- (void) poll;
- (int) read:(uint8_t *)buffer maxLength:(unsigned int)length;
- (int) write:(const uint8_t *)buffer maxLength:(unsigned int)length;
@end

@interface NSObject (J3SocketDelegate)
- (void) socketHasDataAvailable:(J3Socket *)socket;
- (void) socket:(J3Socket *)socket hasError:(NSString *)error;
- (void) socketHasSpaceAvailable:(J3Socket *)socket;
@end
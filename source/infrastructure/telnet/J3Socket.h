//
//  J3Socket.h
//  NewTelnet
//
//  Created by Samuel Tesla on 11/10/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <netinet/in.h>
#import "J3ByteDestination.h"

NSString * J3SocketError;

typedef enum J3SocketStatus
{
  J3SocketStatusNotConnected,
  J3SocketStatusConnecting,
  J3SocketStatusConnected,
  J3SocketStatusClosed,
} J3SocketStatus;

@class J3Socket;
@class J3SocketClosedReason;

@protocol J3SocketDelegate
- (void) socketIsConnecting:(J3Socket *)socket;
- (void) socketIsConnected:(J3Socket *)socket;
- (void) socketIsClosedByClient:(J3Socket *)socket;
- (void) socketIsClosedByServer:(J3Socket *)socket;
- (void) socketIsClosed:(J3Socket *)socket withError:(NSString *)errorMessage;
@end

@interface J3SocketException : NSException
@end

@interface J3Socket : NSObject <J3ByteDestination>
{
  NSString * hostname;
  int port;
  int socketfd;
  struct hostent * server;
	struct sockaddr_in server_addr;
  BOOL hasDataAvailable;
  BOOL hasError;
  BOOL hasSpaceAvailable;
  J3SocketStatus status;
  id <NSObject, J3SocketDelegate> delegate;
}

+ (id) socketWithHostname:(NSString *)hostname port:(int)port;
- (id) initWithHostname:(NSString *)hostname port:(int)port;

- (void) close;
- (BOOL) hasDataAvailable;
- (BOOL) hasSpaceAvailable;
- (BOOL) isClosed;
- (BOOL) isConnected;
- (void) open;
- (void) poll;
- (void) setDelegate:(id <NSObject, J3SocketDelegate>)object;
- (J3SocketStatus) status;
- (unsigned int) read:(uint8_t *)buffer maxLength:(unsigned int)length;
- (unsigned int) writeBytes:(const uint8_t *)bytes length:(unsigned int)length;
@end
//
// J3Socket.h
//
// Copyright (c) 2005 3James Software
//

#import <Cocoa/Cocoa.h>
#import <netinet/in.h>
#import "J3ByteDestination.h"

NSString *J3SocketError;

typedef enum J3SocketStatus
{
  J3SocketStatusNotConnected,
  J3SocketStatusConnecting,
  J3SocketStatusConnected,
  J3SocketStatusClosed,
} J3SocketStatus;

#pragma mark -

@class J3Socket;
@class J3SocketClosedReason;

@protocol J3SocketDelegate

- (void) socketIsConnecting:(J3Socket *)socket;
- (void) socketIsConnected:(J3Socket *)socket;
- (void) socketIsClosedByClient:(J3Socket *)socket;
- (void) socketIsClosedByServer:(J3Socket *)socket;
- (void) socketIsClosed:(J3Socket *)socket withError:(NSString *)errorMessage;

@end

#pragma mark -

@interface J3SocketException : NSException

@end

#pragma mark -

@interface J3Socket : NSObject <J3ByteDestination>
{
  NSString *hostname;
  int port;
  int socketfd;
  struct hostent *server;
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
- (unsigned) read:(uint8_t *)buffer maxLength:(unsigned)length;
- (void) setDelegate:(id <NSObject, J3SocketDelegate>)object;
- (J3SocketStatus) status;

@end

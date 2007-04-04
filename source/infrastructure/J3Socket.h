//
// J3Socket.h
//
// Copyright (c) 2007 3James Software.
//

#import <Cocoa/Cocoa.h>
#import <netinet/in.h>
#import "J3ByteDestination.h"
#import "J3ByteSource.h"

NSString *J3SocketError;

typedef enum J3SocketStatus
{
  J3SocketStatusNotConnected,
  J3SocketStatusConnecting,
  J3SocketStatusConnected,
  J3SocketStatusClosed
} J3SocketStatus;

#pragma mark -

@interface J3SocketException : NSException

+ (void) socketError: (NSString *) errorMessage;
+ (void) socketErrorFormat: (NSString *) format arguments: (va_list)args;

@end

#pragma mark -

@protocol J3Socket

- (void) close;
- (BOOL) isClosed;
- (BOOL) isConnected;
- (void) open;
- (void) poll;

@end

#pragma mark -

@protocol J3SocketDelegate;

@interface J3Socket : NSObject <J3Socket, J3ByteDestination, J3ByteSource>
{
  NSString *hostname;
  int port;
  int socketfd;
  struct hostent *server;
  struct sockaddr_in server_addr;
  BOOL hasDataAvailable;
  BOOL hasError;
  J3SocketStatus status;
  NSObject <J3SocketDelegate> *delegate;
}

+ (id) socketWithHostname: (NSString *) hostname port: (int) port;

- (id) initWithHostname: (NSString *) hostname port: (int) port;

- (BOOL) hasDataAvailable;
- (BOOL) hasSpaceAvailable;
- (BOOL) isConnecting;
- (void) setDelegate: (NSObject <J3SocketDelegate> *) object;
- (J3SocketStatus) status;

@end

#pragma mark -

@protocol J3SocketDelegate

- (void) socketIsConnecting: (NSObject <J3Socket> *) socket;
- (void) socketIsConnected: (NSObject <J3Socket> *) socket;
- (void) socketWasClosedByClient: (NSObject <J3Socket> *) socket;
- (void) socketWasClosedByServer: (NSObject <J3Socket> *) socket;
- (void) socketWasClosed: (NSObject <J3Socket> *) connection withError: (NSString *) errorMessage;

@end

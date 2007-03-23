//
// J3Socket.h
//
// Copyright (c) 2005, 2006 3James Software
//

#import <Cocoa/Cocoa.h>
#import <netinet/in.h>
#import "J3ByteDestination.h"
#import "J3ByteSource.h"
#import "J3Connection.h"

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

@interface J3Socket : NSObject <J3ByteDestination, J3ByteSource, J3Connection>
{
  NSString *hostname;
  int port;
  int socketfd;
  struct hostent *server;
  struct sockaddr_in server_addr;
  BOOL hasDataAvailable;
  BOOL hasError;
  J3SocketStatus status;
  NSObject <J3ConnectionDelegate> *delegate;
}

+ (id) socketWithHostname: (NSString *) hostname port: (int) port;

- (id) initWithHostname: (NSString *) hostname port: (int) port;

- (void) close;
- (BOOL) hasDataAvailable;
- (BOOL) hasSpaceAvailable;
- (BOOL) isClosed;
- (BOOL) isConnected;
- (BOOL) isConnecting;
- (void) open;
- (void) poll;
- (void) setDelegate: (NSObject <J3ConnectionDelegate> *) object;
- (J3SocketStatus) status;

@end

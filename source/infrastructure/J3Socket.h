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
+ (void) socketErrorWithFormat: (NSString *) format, ...;

@end

#pragma mark -

@protocol J3SocketDelegate;

@interface J3Socket : NSObject <J3ByteDestination, J3ByteSource>
{
  NSString *hostname;
  int port;
  int socketfd;
  int kq;
  struct hostent *server;
  unsigned availableBytes;
  BOOL hasError;
  J3SocketStatus status;
  NSObject <J3SocketDelegate> *delegate;
  NSMutableArray *dataToWrite;
  NSObject *availableBytesLock;
}

+ (id) socketWithHostname: (NSString *) hostname port: (int) port;

- (id) initWithHostname: (NSString *) hostname port: (int) port;

- (void) close;
- (BOOL) isClosed;
- (BOOL) isConnected;
- (BOOL) isConnecting;
- (void) open;
- (void) setDelegate: (NSObject <J3SocketDelegate> *) object;
- (J3SocketStatus) status;

@end

#pragma mark -

@protocol J3SocketDelegate

- (void) socketIsConnecting: (J3Socket *) socket;
- (void) socketIsConnected: (J3Socket *) socket;
- (void) socketWasClosedByClient: (J3Socket *) socket;
- (void) socketWasClosedByServer: (J3Socket *) socket;
- (void) socketWasClosed: (J3Socket *) connection withError: (NSString *) errorMessage;

@end

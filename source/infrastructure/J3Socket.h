//
// J3Socket.h
//
// Copyright (c) 2010 3James Software.
//

#import <Cocoa/Cocoa.h>
#import <netinet/in.h>

#import "J3ByteDestination.h"
#import "J3ByteSource.h"
#import "J3Connection.h"

@protocol J3SocketDelegate;

NSString *J3SocketError;

extern NSString *J3SocketDidConnectNotification;
extern NSString *J3SocketIsConnectingNotification;
extern NSString *J3SocketWasClosedByClientNotification;
extern NSString *J3SocketWasClosedByServerNotification;
extern NSString *J3SocketWasClosedWithErrorNotification;
extern NSString *J3SocketErrorMessageKey;

#pragma mark -

@interface J3SocketException : NSException

+ (void) socketError: (NSString *) errorMessage;
+ (void) socketErrorWithFormat: (NSString *) format, ...;

@end

#pragma mark -

@interface J3Socket : J3Connection <J3ByteDestination, J3ByteSource>
{
  NSObject <J3SocketDelegate> *delegate;
  
  NSString *hostname;
  int port;
  int socketfd;
  int kq;
  struct hostent *server;
  unsigned availableBytes;
  BOOL hasError;
  NSMutableArray *dataToWrite;
  NSObject *dataToWriteLock;
  NSObject *availableBytesLock;
}

+ (id) socketWithHostname: (NSString *) hostname port: (int) port;

- (id) initWithHostname: (NSString *) hostname port: (int) port;

- (NSObject <J3SocketDelegate> *) delegate;
- (void) setDelegate: (NSObject <J3SocketDelegate> *) object;

@end

#pragma mark -

@protocol J3SocketDelegate

- (void) socketDidConnect: (NSNotification *) notification;
- (void) socketIsConnecting: (NSNotification *) notification;
- (void) socketWasClosedByClient: (NSNotification *) notification;
- (void) socketWasClosedByServer: (NSNotification *) notification;
- (void) socketWasClosedWithError: (NSNotification *) notification;

@end

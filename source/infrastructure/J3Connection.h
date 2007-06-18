//
// J3Connection.h
//
// Copyright (c) 2007 3James Software.
//

#import <Cocoa/Cocoa.h>

@protocol J3ConnectionDelegate;

typedef enum J3ConnectionStatus
{
  J3ConnectionStatusNotConnected,
  J3ConnectionStatusConnecting,
  J3ConnectionStatusConnected,
  J3ConnectionStatusClosed
} J3ConnectionStatus;

@interface J3Connection : NSObject
{
  id <J3ConnectionDelegate> delegate;
  J3ConnectionStatus status;
}

- (void) setDelegate: (id <J3ConnectionDelegate>) object;

- (void) close;
- (BOOL) isClosed;
- (BOOL) isConnected;
- (BOOL) isConnecting;
- (void) open;

@end

@interface J3Connection (Protected)

- (void) setStatusConnected;
- (void) setStatusConnecting;
- (void) setStatusClosedByClient;
- (void) setStatusClosedByServer;
- (void) setStatusClosedWithError: (NSString *) error;

@end

extern NSString *J3ConnectionDidConnectNotification;
extern NSString *J3ConnectionIsConnectingNotification;
extern NSString *J3ConnectionWasClosedByClientNotification;
extern NSString *J3ConnectionWasClosedByServerNotification;
extern NSString *J3ConnectionWasClosedWithErrorNotification;
extern NSString *J3ConnectionErrorMessageKey;

@protocol J3ConnectionDelegate

- (void) connectionDidConnect: (NSNotification *) notification;
- (void) connectionIsConnecting: (NSNotification *) notification;
- (void) connectionWasClosedByClient: (NSNotification *) notification;
- (void) connectionWasClosedByServer: (NSNotification *) notification;
- (void) connectionWasClosedWithError: (NSNotification *) notification;

@end

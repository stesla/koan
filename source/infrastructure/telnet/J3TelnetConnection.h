//
// J3TelnetConnection.h
//
// Copyright (c) 2010 3James Software.
//

#import <Cocoa/Cocoa.h>

#import "J3ReadBuffer.h"
#import "J3ByteDestination.h"
#import "J3ByteSource.h"
#import "J3Socket.h"
#import "J3WriteBuffer.h"
#import "J3TelnetEngine.h"
#import "J3Connection.h"

@class J3SocketFactory;
@protocol J3TelnetConnectionDelegate;

extern NSString *J3TelnetConnectionDidConnectNotification;
extern NSString *J3TelnetConnectionIsConnectingNotification;
extern NSString *J3TelnetConnectionWasClosedByClientNotification;
extern NSString *J3TelnetConnectionWasClosedByServerNotification;
extern NSString *J3TelnetConnectionWasClosedWithErrorNotification;
extern NSString *J3TelnetConnectionErrorMessageKey;

@interface J3TelnetConnection : J3Connection <J3TelnetEngineDelegate, J3SocketDelegate>
{
  NSObject <J3TelnetConnectionDelegate> *delegate;
  
  J3SocketFactory *socketFactory;
  NSString *hostname;
  int port;
  J3Socket *socket;
  J3ReadBuffer *readBuffer;
  J3TelnetEngine *engine;
  NSTimer *pollTimer;
}

+ (id) telnetWithSocketFactory: (J3SocketFactory *) factory
                      hostname: (NSString *) hostname
                          port: (int) port
                      delegate: (NSObject <J3TelnetConnectionDelegate> *) delegate;
+ (id) telnetWithHostname: (NSString *) hostname
                     port: (int) port
                 delegate: (NSObject <J3TelnetConnectionDelegate> *) delegate;

- (id) initWithSocketFactory: (J3SocketFactory *) factory
                    hostname: (NSString *) hostname
                        port: (int) port
                    delegate: (NSObject <J3TelnetConnectionDelegate> *) delegate;

- (NSObject <J3TelnetConnectionDelegate> *) delegate;
- (void) setDelegate: (NSObject <J3TelnetConnectionDelegate> *) object;

- (BOOL) hasReadBuffer: (NSObject <J3ReadBuffer> *) buffer;
- (void) writeLine: (NSString *) line;

@end

#pragma mark -

@protocol J3TelnetConnectionDelegate

- (void) displayString: (NSString *) string;

- (void) telnetConnectionDidConnect: (NSNotification *) notification;
- (void) telnetConnectionIsConnecting: (NSNotification *) notification;
- (void) telnetConnectionWasClosedByClient: (NSNotification *) notification;
- (void) telnetConnectionWasClosedByServer: (NSNotification *) notification;
- (void) telnetConnectionWasClosedWithError: (NSNotification *) notification;

@end

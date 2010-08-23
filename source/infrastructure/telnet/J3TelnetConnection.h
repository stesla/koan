//
// J3TelnetConnection.h
//
// Copyright (c) 2010 3James Software.
//

#import <Cocoa/Cocoa.h>

#import "J3ByteDestination.h"
#import "J3ByteSource.h"
#import "J3Connection.h"
#import "J3Protocol.h"
#import "J3Socket.h"
#import "J3TelnetConnectionState.h"
#import "J3TelnetProtocolHandler.h"
#import "J3WriteBuffer.h"

@class J3SocketFactory;
@protocol J3TelnetConnectionDelegate;

extern NSString *J3TelnetConnectionDidConnectNotification;
extern NSString *J3TelnetConnectionIsConnectingNotification;
extern NSString *J3TelnetConnectionWasClosedByClientNotification;
extern NSString *J3TelnetConnectionWasClosedByServerNotification;
extern NSString *J3TelnetConnectionWasClosedWithErrorNotification;
extern NSString *J3TelnetConnectionErrorMessageKey;

@interface J3TelnetConnection : J3Connection <J3SocketDelegate, J3TelnetProtocolHandlerDelegate>
{
  NSObject <J3TelnetConnectionDelegate> *delegate;
  J3TelnetConnectionState *state;
  J3ProtocolStack *protocolStack;
  
  J3SocketFactory *socketFactory;
  
  NSString *hostname;
  int port;
  J3Socket *socket;
  NSTimer *pollTimer;
}

@property (assign, nonatomic) NSObject <J3TelnetConnectionDelegate> *delegate;
@property (retain, nonatomic) J3Socket *socket;
@property (retain, nonatomic) J3TelnetConnectionState *state;

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

- (void) log: (NSString *) message, ...;
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

//
// J3TelnetConnection.h
//
// Copyright (c) 2007 3James Software.
//

#import <Cocoa/Cocoa.h>

#import "J3ReadBuffer.h"
#import "J3ByteDestination.h"
#import "J3ByteSource.h"
#import "J3Socket.h"
#import "J3WriteBuffer.h"
#import "J3TelnetEngine.h"

@class J3SocketFactory;
@protocol J3TelnetConnectionDelegate;
@protocol J3TelnetEngineDelegate;

@interface J3TelnetConnection : NSObject <J3SocketDelegate, J3TelnetEngineDelegate>
{
  J3SocketFactory *socketFactory;
  NSString *hostname;
  int port;
  J3Socket *socket;
  J3ReadBuffer *inputBuffer;
  J3TelnetEngine *engine;
  NSTimer *pollTimer;
  NSObject <J3TelnetConnectionDelegate> *delegate;
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

- (void) close;
- (BOOL) isConnected;
- (BOOL) hasInputBuffer: (NSObject <J3ReadBuffer> *) buffer;
- (void) open;
- (void) setDelegate: (NSObject <J3TelnetConnectionDelegate> *) object;
- (void) writeLine: (NSString *) line;

@end

#pragma mark -

@protocol J3TelnetConnectionDelegate

- (void) telnetConnectionIsConnecting: (J3TelnetConnection *) connection;
- (void) telnetConnectionIsConnected: (J3TelnetConnection *) connection;
- (void) telnetConnectionWasClosedByClient: (J3TelnetConnection *) connection;
- (void) telnetConnectionWasClosedByServer: (J3TelnetConnection *) connection;
- (void) telnetConnectionWasClosed: (J3TelnetConnection *) connection withError: (NSString *) errorMessage;

@end

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
#import "J3ConnectionDelegate.h"

@class J3SocketFactory;
@protocol J3TelnetEngineDelegate;

@interface J3TelnetConnection : NSObject <J3TelnetEngineDelegate, J3ConnectionDelegate>
{
  J3SocketFactory *socketFactory;
  NSString *hostname;
  int port;
  J3Socket *socket;
  J3ReadBuffer *inputBuffer;
  J3TelnetEngine *engine;
  NSTimer *pollTimer;
  NSObject <J3ConnectionDelegate> *delegate;
}

+ (id) telnetWithSocketFactory: (J3SocketFactory *) factory
                      hostname: (NSString *) hostname
                          port: (int) port
                      delegate: (NSObject <J3ConnectionDelegate> *) delegate;
+ (id) telnetWithHostname: (NSString *) hostname
                     port: (int) port
                 delegate: (NSObject <J3ConnectionDelegate> *) delegate;

- (id) initWithSocketFactory: (J3SocketFactory *) factory
                    hostname: (NSString *) hostname
                        port: (int) port
                    delegate: (NSObject <J3ConnectionDelegate> *) delegate;

- (void) close;
- (BOOL) isConnected;
- (BOOL) hasInputBuffer: (NSObject <J3ReadBuffer> *) buffer;
- (void) open;
- (void) setDelegate: (NSObject <J3ConnectionDelegate> *) object;
- (void) writeLine: (NSString *) line;

@end

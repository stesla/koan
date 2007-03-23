//
// J3TelnetConnection.h
//
// Copyright (c) 2005, 2006, 2007 3James Software
//

#import <Cocoa/Cocoa.h>

#import "J3Buffer.h"
#import "J3ByteDestination.h"
#import "J3ByteSource.h"
#import "J3Connection.h"
#import "J3WriteBuffer.h"
#import "J3TelnetEngine.h"

@protocol J3TelnetConnectionDelegate;

@interface J3TelnetConnection : NSObject <J3ConnectionDelegate>
{
  NSObject <J3ByteDestination, J3ByteSource, J3Connection> *connection;
  J3WriteBuffer *outputBuffer;
  J3TelnetEngine *engine;
  NSMutableDictionary *timers;
  NSObject <J3TelnetConnectionDelegate> *delegate;
}

- (id) initWithConnection: (NSObject <J3ByteDestination, J3ByteSource, J3Connection> *) newConnection
                   engine: (J3TelnetEngine *) newParser
                 delegate: (NSObject <J3TelnetConnectionDelegate> *) newDelegate;

- (void) close;
- (BOOL) isConnected;
- (BOOL) hasInputBuffer: (NSObject <J3Buffer> *) buffer;
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

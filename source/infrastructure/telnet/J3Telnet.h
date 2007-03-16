//
// J3Telnet.h
//
// Copyright (c) 2005, 2006 3James Software
//

#import <Cocoa/Cocoa.h>

#import "J3Buffer.h"
#import "J3ByteDestination.h"
#import "J3ByteSource.h"
#import "J3Connection.h"
#import "J3WriteBuffer.h"
#import "J3TelnetParser.h"

@protocol J3TelnetConnectionDelegate;

@interface J3Telnet : NSObject <J3ConnectionDelegate>
{
  NSObject <J3ByteDestination, J3ByteSource, J3Connection> *connection;
  J3WriteBuffer *outputBuffer;
  J3TelnetParser *parser;
  NSMutableDictionary *timers;
  NSObject <J3TelnetConnectionDelegate> *delegate;
}

- (id) initWithConnection:(NSObject <J3ByteDestination, J3ByteSource, J3Connection> *)newConnection
                   parser:(J3TelnetParser *)newParser
                 delegate:(NSObject <J3TelnetConnectionDelegate> *)newDelegate;

- (void) close;
- (BOOL) isConnected;
- (BOOL) hasInputBuffer:(NSObject <J3Buffer> *)buffer;
- (void) open;
- (void) setDelegate:(NSObject <J3TelnetConnectionDelegate> *)object;
- (void) writeLine:(NSString *)line;
- (void) writeString:(NSString *)string;

@end

#pragma mark -

@protocol J3TelnetConnectionDelegate

- (void) telnetConnectionIsConnecting:(J3Telnet *)connection;
- (void) telnetConnectionIsConnected:(J3Telnet *)connection;
- (void) telnetConnectionWasClosedByClient:(J3Telnet *)connection;
- (void) telnetConnectionWasClosedByServer:(J3Telnet *)connection;
- (void) telnetConnectionWasClosed:(J3Telnet *)connection withError:(NSString *)errorMessage;

@end

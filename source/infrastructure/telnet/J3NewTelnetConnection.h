//
// J3NewTelnetConnection.h
//
// Copyright (c) 2005 3James Software
//

#import <Cocoa/Cocoa.h>

#import "J3Buffer.h"
#import "J3LineBuffer.h"
#import "J3Socket.h"
#import "J3WriteBuffer.h"
#import "J3TelnetParser.h"

@interface J3NewTelnetConnection : NSObject 
{
  J3Socket *socket;
  J3WriteBuffer *outputBuffer;
  J3TelnetParser *parser;
  NSMutableDictionary *timers;
}

+ (id) lineAtATimeTelnetWithHostname:(NSString *)hostname
                                port:(int)port
                            delegate:(id <NSObject, J3LineBufferDelegate, J3SocketDelegate>)delegate;

+ (id) telnetWithHostname:(NSString *)hostname
                     port:(int)port
              inputBuffer:(id <NSObject, J3Buffer>)buffer
           socketDelegate:(id <NSObject, J3SocketDelegate>)delegate;

- (id) initWithSocket:(J3Socket *)newSocket parser:(J3TelnetParser *)newParser;

- (void) close;
- (BOOL) isConnected;
- (void) open;
- (void) removeFromRunLoop:(NSRunLoop *)runLoop forMode:(NSString *)mode;
- (void) scheduleInRunLoop:(NSRunLoop *)runLoop forMode:(NSString *)mode;
- (void) writeLine:(NSString *)line;
- (void) writeString:(NSString *)string;

@end

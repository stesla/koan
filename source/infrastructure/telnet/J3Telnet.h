//
// J3Telnet.h
//
// Copyright (c) 2005 3James Software
//

#import <Cocoa/Cocoa.h>

#import "J3Buffer.h"
#import "J3ByteDestination.h"
#import "J3ByteSource.h"
#import "J3Connection.h"
#import "J3LineBuffer.h"
#import "J3Socket.h"
#import "J3WriteBuffer.h"
#import "J3TelnetParser.h"

@interface J3Telnet : NSObject 
{
  id <NSObject, J3ByteDestination, J3ByteSource, J3Connection> socket;
  J3WriteBuffer *outputBuffer;
  J3TelnetParser *parser;
  NSMutableDictionary *timers;
}

+ (id) lineAtATimeTelnetWithHostname:(NSString *)hostname
                                port:(int)port
                            delegate:(id <NSObject, J3LineBufferDelegate, J3ConnectionDelegate>)delegate;

+ (id) telnetWithHostname:(NSString *)hostname
                     port:(int)port
              inputBuffer:(id <NSObject, J3Buffer>)buffer
           socketDelegate:(id <NSObject, J3ConnectionDelegate>)delegate;

- (id) initWithSocket:(id <NSObject, J3ByteDestination, J3ByteSource, J3Connection>)newSocket parser:(J3TelnetParser *)newParser;

- (void) close;
- (BOOL) isConnected;
- (void) open;
- (void) removeFromRunLoop:(NSRunLoop *)runLoop forMode:(NSString *)mode;
- (void) scheduleInRunLoop:(NSRunLoop *)runLoop forMode:(NSString *)mode;
- (void) writeLine:(NSString *)line;
- (void) writeString:(NSString *)string;

@end

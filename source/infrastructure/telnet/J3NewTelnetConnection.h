//
//  J3NewTelnetConnection.h
//  Koan
//
//  Created by Samuel Tesla on 11/16/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "J3Buffer.h"
#import "J3LineBuffer.h"
#import "J3Socket.h"
#import "J3WriteBuffer.h"
#import "J3TelnetParser.h"

@interface J3NewTelnetConnection : NSObject 
{
  J3Socket * socket;
  J3WriteBuffer * outputBuffer;
  J3TelnetParser * parser;
  NSMutableDictionary * timers;
}

+ (id) lineAtATimeTelnetWithHostname:(NSString *)hostname port:(int)port delegate:(id <NSObject, J3LineBufferDelegate, J3SocketDelegate>)delegate;
+ (id) telnetWithHostname:(NSString *)hostname port:(int)port inputBuffer:(id <NSObject, J3Buffer>)buffer socketDelegate:(id <NSObject, J3SocketDelegate>)delegate;
- (id) initWithSocket:(J3Socket *)aSocket parser:(J3TelnetParser *)aParser;

- (void) close;
- (BOOL) isConnected;
- (void) open;
- (void) scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode;
- (void) removeFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode;
- (void) writeLine:(NSString *)line;
- (void) writeString:(NSString *)string;
@end

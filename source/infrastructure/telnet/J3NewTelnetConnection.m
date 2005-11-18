//
//  J3NewTelnetConnection.m
//  Koan
//
//  Created by Samuel Tesla on 11/16/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "J3NewTelnetConnection.h"

#define TELNET_READ_BUFFER_SIZE 512

@interface J3NewTelnetConnection (Private)
- (void) poll;
- (void) removeAllTimers;
- (NSString *)timerKeyWithRunLoop:(NSRunLoop *)aRunLoop andMode:(NSString *)mode;
@end

@implementation J3NewTelnetConnection
+ (id) lineAtATimeTelnetWithHostname:(NSString *)hostname port:(int)port delegate:(id <NSObject, J3LineBufferDelegate, J3SocketDelegate>)delegate;
{
  J3LineBuffer * buffer = [J3LineBuffer buffer];
  [buffer setDelegate:delegate];
  return [self telnetWithHostname:hostname port:port inputBuffer:buffer socketDelegate:delegate];
}

+ (id) telnetWithHostname:(NSString *)hostname port:(int)port inputBuffer:(id <NSObject, J3Buffer>)buffer socketDelegate:(id <NSObject, J3SocketDelegate>)delegate;
{
  J3Socket * socket = [J3Socket socketWithHostname:hostname port:port];
  J3TelnetParser * parser = [J3TelnetParser parser];
  [socket setDelegate:delegate];
  [parser setInputBuffer:buffer];
  return [[[self alloc] initWithSocket:socket parser:parser] autorelease];
}

- (void) close;
{
  [self removeAllTimers];
  [socket close];
}

- (void) dealloc;
{
  [parser release];
  [outputBuffer release];
  [socket release];
  [super dealloc];
}

- (id) initWithSocket:(J3Socket *)aSocket parser:(J3TelnetParser *)aParser;
{
  if (![super init])
    return nil;
  [self at:&socket put:aSocket];
  [self at:&parser put:aParser];
  [self at:&outputBuffer put:[J3WriteBuffer buffer]];
  [self at:&timers put:[NSMutableDictionary dictionary]];
  [outputBuffer setByteDestination:socket];
  [parser setOuptutBuffer:outputBuffer];
  return self;
}

- (BOOL) isConnected;
{
  return [socket isConnected];
}

- (void) open;
{
  [socket open];
}

- (void) timerFire:(NSTimer*)aTimer;
{
  [self poll];
}

- (void) scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode;
{
  NSTimer * timer = [NSTimer timerWithTimeInterval:0.0 target:self selector:@selector(timerFire:) userInfo:nil repeats:YES];
  [aRunLoop addTimer:timer forMode:mode];
  [timers setObject:timer forKey:[self timerKeyWithRunLoop:aRunLoop andMode:mode]];
}

- (void) removeFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode;
{
  NSTimer * timer = [timers objectForKey:[self timerKeyWithRunLoop:aRunLoop andMode:mode]];
  [timer invalidate];
}

- (void) writeLine:(NSString *)line;
{
  [outputBuffer appendLine:line];
}

- (void) writeString:(NSString *)string;
{
  [outputBuffer appendString:string];
}
@end

@implementation J3NewTelnetConnection (Private)
- (void) poll;
{
  uint8_t bytes[TELNET_READ_BUFFER_SIZE];
  unsigned int bytesRead = 0;
  
  [socket poll];
  if ([socket hasDataAvailable])
  {
    bytesRead = [socket read:bytes maxLength:TELNET_READ_BUFFER_SIZE];
    [parser parse:bytes length:bytesRead];
  }
  if ([socket hasSpaceAvailable])
    [outputBuffer write];
}

- (void) removeAllTimers;
{
  NSEnumerator * keys = [timers objectEnumerator];
  NSTimer * timer;
  while (timer = [keys nextObject])
    [timer invalidate];
}

- (NSString *)timerKeyWithRunLoop:(NSRunLoop *)aRunLoop andMode:(NSString *)mode;
{
  return [NSString stringWithFormat:@"%@%@", aRunLoop, mode];
}
@end

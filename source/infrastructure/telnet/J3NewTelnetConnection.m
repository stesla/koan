//
//  J3NewTelnetConnection.m
//  Koan
//
//  Created by Samuel Tesla on 11/16/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "J3NewTelnetConnection.h"

@interface J3NewTelnetConnection (Private)
- (void) poll;
- (void) removeAllTimers;
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
  [socket close];
}

- (void) dealloc;
{
  [self removeAllTimers];
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
  [timers setObject:timer forKey:mode];
}

- (void) removeFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode;
{
  NSTimer * timer = [timers objectForKey:mode];
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
  uint8_t bytes[1];
  
  [socket poll];
  if ([socket hasDataAvailable])
  {
    [socket read:bytes maxLength:1];
    [parser parse:bytes[0]];
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
@end

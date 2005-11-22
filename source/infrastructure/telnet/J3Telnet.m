//
// J3Telnet.m
//
// Copyright (c) 2005 3James Software
//

#import "J3Telnet.h"

#define TELNET_READ_BUFFER_SIZE 512

@interface J3Telnet (Private)

- (void) fireTimer:(NSTimer *)timer;
- (void) poll;
- (void) removeAllTimers;
- (NSString *)timerKeyWithRunLoop:(NSRunLoop *)runLoop mode:(NSString *)mode;

@end

#pragma mark -

@implementation J3Telnet

+ (id) lineAtATimeTelnetWithHostname:(NSString *)hostname
                                port:(int)port
                            delegate:(id <NSObject, J3LineBufferDelegate, J3ConnectionDelegate>)delegate
{
  J3LineBuffer *buffer = [J3LineBuffer buffer];
  
  [buffer setDelegate:delegate];
  
  return [self telnetWithHostname:hostname port:port inputBuffer:buffer socketDelegate:delegate];
}

+ (id) telnetWithHostname:(NSString *)hostname
                     port:(int)port
              inputBuffer:(id <NSObject, J3Buffer>)buffer
           socketDelegate:(id <NSObject, J3ConnectionDelegate>)delegate
{
  J3Socket * newSocket = [J3Socket socketWithHostname:hostname port:port];
  J3TelnetParser *newParser = [J3TelnetParser parser];
  
  [newSocket setDelegate:delegate];
  [newParser setInputBuffer:buffer];
  
  return [[[self alloc] initWithConnection:newSocket parser:newParser] autorelease];
}

- (id) initWithConnection:(id <NSObject, J3ByteDestination, J3ByteSource, J3Connection>)newConnection parser:(J3TelnetParser *)newParser;
{
  if (![super init])
    return nil;
  [self at:&connection put:newConnection];
  [self at:&parser put:newParser];
  [self at:&outputBuffer put:[J3WriteBuffer buffer]];
  [self at:&timers put:[NSMutableDictionary dictionary]];
  [outputBuffer setByteDestination:connection];
  [parser setOuptutBuffer:outputBuffer];
  return self;
}

- (void) dealloc
{
  if ([self isConnected])
    [self close];
  [parser release];
  [outputBuffer release];
  [connection release];
  [super dealloc];
}

- (void) close
{
  [self removeAllTimers];
  [connection close];
}

- (BOOL) hasInputBuffer:(id <J3Buffer>)buffer;
{
  return [parser hasInputBuffer: buffer];
}

- (BOOL) isConnected
{
  return [connection isConnected];
}

- (BOOL) isOnConnection:(id <J3Connection>)aConnection;
{
  return aConnection == connection;
}

- (void) open
{
  [connection open];
}

- (void) removeFromRunLoop:(NSRunLoop *)runLoop forMode:(NSString *)mode
{
  NSTimer *timer = [timers objectForKey:[self timerKeyWithRunLoop:runLoop mode:mode]];
  [timer invalidate];
}

- (void) scheduleInRunLoop:(NSRunLoop *)runLoop forMode:(NSString *)mode
{
  NSTimer *timer = [NSTimer timerWithTimeInterval:0.0 target:self selector:@selector(fireTimer:) userInfo:nil repeats:YES];
  [runLoop addTimer:timer forMode:mode];
  [timers setObject:timer forKey:[self timerKeyWithRunLoop:runLoop mode:mode]];
}

- (void) writeLine:(NSString *)line
{
  [outputBuffer appendLine:line];
  [outputBuffer flush];
}

- (void) writeString:(NSString *)string
{
  [outputBuffer appendString:string];
  [outputBuffer flush];
}

@end

#pragma mark -

@implementation J3Telnet (Private)

- (void) fireTimer:(NSTimer *)timer
{
  [self poll];
}

- (void) poll
{
  uint8_t bytes[TELNET_READ_BUFFER_SIZE];
  unsigned bytesRead = 0;
  
  if (![connection isConnected])
    return;
  
  [connection poll];
  if ([connection hasDataAvailable])
  {
    bytesRead = [connection read:bytes maxLength:TELNET_READ_BUFFER_SIZE];
    [parser parse:bytes length:bytesRead];
  }
}

- (void) removeAllTimers
{
  NSEnumerator *keys = [timers objectEnumerator];
  NSTimer *timer;
  while (timer = [keys nextObject])
    [timer invalidate];
}

- (NSString *) timerKeyWithRunLoop:(NSRunLoop *)runLoop mode:(NSString *)mode
{
  return [NSString stringWithFormat:@"%@%@", runLoop, mode];
}

@end

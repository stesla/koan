//
// J3Telnet.m
//
// Copyright (c) 2005 3James Software
//

#import "J3Telnet.h"

#define TELNET_READ_BUFFER_SIZE 512

#pragma mark -

@interface J3Telnet (Private)

- (void) fireTimer:(NSTimer *)timer;
- (BOOL) isOnConnection:(id <J3Connection>)connection;
- (void) poll;
- (void) removeAllTimers;
- (void) scheduleInRunLoop:(NSRunLoop *)runLoop forMode:(NSString *)mode;
- (NSString *) timerKeyWithRunLoop:(NSRunLoop *)runLoop mode:(NSString *)mode;

@end

#pragma mark -

@implementation J3Telnet

+ (id) lineAtATimeTelnetWithHostname:(NSString *)hostname
                                port:(int)port
                            delegate:(NSObject <J3TelnetConnectionDelegate> *)newDelegate
                  lineBufferDelegate:(NSObject <J3LineBufferDelegate> *)lineBufferDelegate
{
  J3LineBuffer *buffer = [J3LineBuffer buffer];
  
  [buffer setDelegate:lineBufferDelegate];
  
  return [self telnetWithHostname:hostname port:port inputBuffer:buffer delegate:newDelegate];
}

+ (id) telnetWithHostname:(NSString *)hostname
                     port:(int)port
              inputBuffer:(NSObject <J3Buffer> *)buffer
                 delegate:(NSObject <J3TelnetConnectionDelegate> *)newDelegate
{
  J3TelnetParser *newParser = [J3TelnetParser parser];
  
  [newParser setInputBuffer:buffer];
  
  return [[[self alloc] initWithHostname:hostname port:port parser:newParser delegate:newDelegate] autorelease];
}

- (id) initWithHostname:(NSString *)hostname
                   port:(int)port
                 parser:(J3TelnetParser *)newParser
               delegate:(NSObject <J3TelnetConnectionDelegate> *)newDelegate
{
  J3Socket *newSocket = [J3Socket socketWithHostname:hostname port:port];
  
  [newSocket setDelegate:self];
  
  return [[self initWithConnection:newSocket parser:newParser delegate:newDelegate] autorelease];
}

- (id) initWithConnection:(NSObject <J3ByteDestination, J3ByteSource, J3Connection> *)newConnection
                   parser:(J3TelnetParser *)newParser
                 delegate:(NSObject <J3TelnetConnectionDelegate> *)newDelegate
{
  if (![super init])
    return nil;
  
  [self setDelegate:delegate];
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
  
  [self removeAllTimers];
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

- (BOOL) hasInputBuffer:(NSObject <J3Buffer> *)buffer;
{
  return [parser hasInputBuffer: buffer];
}

- (BOOL) isConnected
{
  return [connection isConnected];
}

- (void) open
{
  [self scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
  [connection open];
}

- (void) setDelegate:(NSObject <J3TelnetConnectionDelegate> *)object
{
  [self at:&delegate put:object];
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

#pragma mark -
#pragma mark J3ConnectionDelegate protocol

- (void) connectionIsConnecting:(id <J3Connection>)delegateConnection
{
  if (![self isOnConnection:delegateConnection])
    return;
  
  if (delegate && [delegate respondsToSelector:@selector(telnetConnectionIsConnecting:)])
    [delegate telnetConnectionIsConnecting:self];
}

- (void) connectionIsConnected:(id <J3Connection>)delegateConnection
{
  if (![self isOnConnection:delegateConnection])
    return;
  
  if (delegate && [delegate respondsToSelector:@selector(telnetConnectionIsConnected:)])
    [delegate telnetConnectionIsConnected:self];
}

- (void) connectionWasClosedByClient:(id <J3Connection>)delegateConnection
{
  if (![self isOnConnection:delegateConnection])
    return;
  
  [self removeAllTimers];
  if (delegate && [delegate respondsToSelector:@selector(telnetConnectionWasClosedByClient:)])
    [delegate telnetConnectionWasClosedByClient:self];
}

- (void) connectionWasClosedByServer:(id <J3Connection>)delegateConnection
{
  if (![self isOnConnection:delegateConnection])
    return;
  
  [self removeAllTimers];
  if (delegate && [delegate respondsToSelector:@selector(telnetConnectionWasClosedByServer:)])
    [delegate telnetConnectionWasClosedByServer:self];
}

- (void) connectionWasClosed:(id <J3Connection>)delegateConnection withError:(NSString *)errorMessage
{
  if (![self isOnConnection:delegateConnection])
    return;
  
  [self removeAllTimers];
  if (delegate && [delegate respondsToSelector:@selector(telnetConnectionWasClosed:withError:)])
    [delegate telnetConnectionWasClosed:self withError:errorMessage];
}

@end

#pragma mark -

@implementation J3Telnet (Private)

- (void) fireTimer:(NSTimer *)timer
{
  [self poll];
}

- (BOOL) isOnConnection:(id <J3Connection>)aConnection;
{
  return aConnection == connection;
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
  NSEnumerator *keys = [timers keyEnumerator];
  NSString *key;
  
  while (key = [keys nextObject])
  {
    NSTimer *timer = [timers objectForKey:key];
    
    [timer invalidate];
    [timers removeObjectForKey:key];
  }
}

- (void) scheduleInRunLoop:(NSRunLoop *)runLoop forMode:(NSString *)mode
{
  NSTimer *timer = [NSTimer timerWithTimeInterval:0.0 target:self selector:@selector(fireTimer:) userInfo:nil repeats:YES];
  
  [runLoop addTimer:timer forMode:mode];
  [timers setObject:timer forKey:[self timerKeyWithRunLoop:runLoop mode:mode]];
}

- (NSString *) timerKeyWithRunLoop:(NSRunLoop *)runLoop mode:(NSString *)mode
{
  return [NSString stringWithFormat:@"%@%@", runLoop, mode];
}

@end

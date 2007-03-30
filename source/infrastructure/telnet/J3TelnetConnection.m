//
// J3TelnetConnection.m
//
// Copyright (c) 2005, 2006, 2007 3James Software
//

#import "J3TelnetConnection.h"

#define TELNET_READ_BUFFER_SIZE 512

#pragma mark -

@interface J3TelnetConnection (Private)

- (void) fireTimer: (NSTimer *) timer;
- (BOOL) isOnConnection: (id <J3Connection>) connection;
- (void) poll;
- (void) removeAllTimers;
- (void) scheduleInRunLoop: (NSRunLoop *) runLoop forMode: (NSString *) mode;
- (NSString *) timerKeyWithRunLoop: (NSRunLoop *) runLoop mode: (NSString *) mode;

@end

#pragma mark -

@implementation J3TelnetConnection

- (id) initWithConnection: (NSObject <J3ByteDestination, J3ByteSource, J3Connection> *) newConnection
                   engine: (J3TelnetEngine *) newEngine
                 delegate: (NSObject <J3TelnetConnectionDelegate> *) newDelegate
{
  if (![super init])
    return nil;
  
  [self setDelegate: newDelegate];
  [self at: &connection put: newConnection];
  [self at: &engine put: newEngine];
  [self at: &timers put: [NSMutableDictionary dictionary]];
  [self at: &outputBuffer put: [J3WriteBuffer buffer]];
  [outputBuffer setByteDestination: connection];
  [engine setOutputBuffer: outputBuffer];
  
  return self;
}

- (void) dealloc
{
  delegate = nil;
  [self close];
  [self removeAllTimers];
  [engine release];
  [outputBuffer release];
  [connection release];
  [super dealloc];
}

- (void) close
{
  [self removeAllTimers];
  if (!connection)
    return;
  [connection close];
  [connection release];
  connection = nil;
}

- (BOOL) hasInputBuffer: (NSObject <J3ReadBuffer> *) buffer;
{
  return [engine hasInputBuffer: buffer];
}

- (BOOL) isConnected
{
  return [connection isConnected];
}

- (void) open
{
  [self scheduleInRunLoop: [NSRunLoop currentRunLoop] forMode: NSDefaultRunLoopMode];
  [connection open];
}

- (void) setDelegate: (NSObject <J3TelnetConnectionDelegate> *) object
{
  [self at: &delegate put: object];
}

- (void) writeLine: (NSString *) line
{
  [outputBuffer appendLine: line];
  [outputBuffer flush];
  // [engine goAhead]; //TODO: Removed as a temporary fix for #26
}

#pragma mark -
#pragma mark J3ConnectionDelegate protocol

- (void) connectionIsConnecting: (id <J3Connection>) delegateConnection
{
  if (![self isOnConnection: delegateConnection])
    return;
  
  if (delegate && [delegate respondsToSelector: @selector (telnetConnectionIsConnecting:)])
    [delegate telnetConnectionIsConnecting: self];
}

- (void) connectionIsConnected: (id <J3Connection>) delegateConnection
{
  if (![self isOnConnection: delegateConnection])
    return;
  
  if (delegate && [delegate respondsToSelector: @selector (telnetConnectionIsConnected:)])
    [delegate telnetConnectionIsConnected: self];
}

- (void) connectionWasClosedByClient: (id <J3Connection>) delegateConnection
{
  if (![self isOnConnection: delegateConnection])
    return;
  
  [self removeAllTimers];
  if (delegate && [delegate respondsToSelector: @selector (telnetConnectionWasClosedByClient:)])
    [delegate telnetConnectionWasClosedByClient: self];
}

- (void) connectionWasClosedByServer: (id <J3Connection>) delegateConnection
{
  if (![self isOnConnection: delegateConnection])
    return;
  
  [self removeAllTimers];
  if (delegate && [delegate respondsToSelector: @selector (telnetConnectionWasClosedByServer:)])
    [delegate telnetConnectionWasClosedByServer: self];
}

- (void) connectionWasClosed: (id <J3Connection>) delegateConnection withError: (NSString *) errorMessage
{
  if (![self isOnConnection: delegateConnection])
    return;
  
  [self removeAllTimers];
  if (delegate && [delegate respondsToSelector: @selector (telnetConnectionWasClosed: withError:)])
    [delegate telnetConnectionWasClosed: self withError: errorMessage];
}

@end

#pragma mark -

@implementation J3TelnetConnection (Private)

- (void) fireTimer: (NSTimer *) timer
{
  [self poll];
}

- (BOOL) isOnConnection: (id <J3Connection>) aConnection;
{
  return aConnection == connection;
}

- (void) poll
{
  // It is possible for the connection to have been released but for there to
  // be a pending timer fire that was registered before the timers were
  // invalidated.
  if (!connection || ![connection isConnected])
    return;
  
  [connection poll];
  if ([connection hasDataAvailable])
  {
    NSData *data = [connection readUpToLength: TELNET_READ_BUFFER_SIZE];
    [engine parse: (uint8_t *)[data bytes] length: [data length]];
  }
  else
    [engine handleEndOfReceivedData];
}

- (void) removeAllTimers
{
  NSEnumerator *keys = [timers keyEnumerator];
  NSString *key;
  
  while ((key = [keys nextObject]))
  {
    NSTimer *timer = [timers objectForKey: key];
    
    [timer invalidate];
    [timers removeObjectForKey: key];
  }
}

- (void) scheduleInRunLoop: (NSRunLoop *) runLoop forMode: (NSString *) mode
{
  NSTimer *timer = [NSTimer timerWithTimeInterval: 0.0 target: self selector: @selector (fireTimer:) userInfo: nil repeats: YES];
  
  [runLoop addTimer: timer forMode: mode];
  [timers setObject: timer forKey: [self timerKeyWithRunLoop: runLoop mode: mode]];
}

- (NSString *) timerKeyWithRunLoop: (NSRunLoop *) runLoop mode: (NSString *) mode
{
  return [NSString stringWithFormat: @"%@%@", runLoop, mode];
}

@end

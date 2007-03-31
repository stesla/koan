//
// J3TelnetConnection.m
//
// Copyright (c) 2005, 2006, 2007 3James Software
//

#import "J3TelnetConnection.h"

#define TELNET_READ_BUFFER_SIZE 512

#pragma mark -

@interface J3TelnetConnection (Private)

- (void) cleanUpConnection;
- (void) cleanUpPollTimer;
- (void) fireTimer: (NSTimer *) timer;
- (BOOL) isOnConnection: (id <J3Connection>) connection;
- (void) poll;
- (void) schedulePollTimer;

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
  [self at: &outputBuffer put: [J3WriteBuffer buffer]];
  [outputBuffer setByteDestination: connection];
  [engine setOutputBuffer: outputBuffer];
  
  pollTimer = nil;
  
  return self;
}

- (void) dealloc
{
  delegate = nil;
  [self close];
  [self cleanUpPollTimer];
  [engine release];
  [outputBuffer release];
  [connection release];
  [super dealloc];
}

- (void) close
{
  [connection close];
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
  [self schedulePollTimer];
  [connection open];
}

- (void) setDelegate: (NSObject <J3TelnetConnectionDelegate> *) object
{
  delegate = object;
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
  
  [self cleanUpPollTimer];
  [self cleanUpConnection];
  
  if (delegate && [delegate respondsToSelector: @selector (telnetConnectionWasClosedByClient:)])
    [delegate telnetConnectionWasClosedByClient: self];
}

- (void) connectionWasClosedByServer: (id <J3Connection>) delegateConnection
{
  if (![self isOnConnection: delegateConnection])
    return;
  
  [self cleanUpPollTimer];
  [self cleanUpConnection];
  
  if (delegate && [delegate respondsToSelector: @selector (telnetConnectionWasClosedByServer:)])
    [delegate telnetConnectionWasClosedByServer: self];
}

- (void) connectionWasClosed: (id <J3Connection>) delegateConnection withError: (NSString *) errorMessage
{
  if (![self isOnConnection: delegateConnection])
    return;
  
  [self cleanUpPollTimer];
  [self cleanUpConnection];
  
  if (delegate && [delegate respondsToSelector: @selector (telnetConnectionWasClosed: withError:)])
    [delegate telnetConnectionWasClosed: self withError: errorMessage];
}

@end

#pragma mark -

@implementation J3TelnetConnection (Private)

- (void) cleanUpConnection
{
  [connection release];
  connection = nil;
}

- (void) cleanUpPollTimer
{
  [pollTimer invalidate];
  pollTimer = nil;
}

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
    [engine parseData: [connection readUpToLength: TELNET_READ_BUFFER_SIZE]];
  else
    [engine handleEndOfReceivedData];
}

- (void) schedulePollTimer
{
  pollTimer = [NSTimer scheduledTimerWithTimeInterval: 0.0
                                               target: self
                                             selector: @selector (fireTimer:)
                                             userInfo: nil
                                              repeats: YES];
}

@end

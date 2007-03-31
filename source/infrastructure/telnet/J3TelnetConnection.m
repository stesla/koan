//
// J3TelnetConnection.m
//
// Copyright (c) 2005, 2006, 2007 3James Software
//

#import "J3TelnetConnection.h"

#define TELNET_READ_BUFFER_SIZE 512

#pragma mark -

@interface J3TelnetConnection (Private)

- (void) cleanUpPollTimer;
- (void) fireTimer: (NSTimer *) timer;
- (BOOL) isUsingSocket: (NSObject <J3Socket> *) possibleSocket;
- (void) poll;
- (void) schedulePollTimer;

@end

#pragma mark -

@implementation J3TelnetConnection

- (id) initWithSocket: (NSObject <J3Socket, J3ByteDestination, J3ByteSource> *) newSocket
               engine: (J3TelnetEngine *) newEngine
             delegate: (NSObject <J3TelnetConnectionDelegate> *) newDelegate
{
  if (![super init])
    return nil;
  
  [self setDelegate: newDelegate];
  [self at: &socket put: newSocket];
  [self at: &engine put: newEngine];
  [self at: &outputBuffer put: [J3WriteBuffer buffer]];
  [outputBuffer setByteDestination: socket];
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
  [socket release];
  [super dealloc];
}

- (void) close
{
  [socket close];
}

- (BOOL) hasInputBuffer: (NSObject <J3ReadBuffer> *) buffer;
{
  return [engine hasInputBuffer: buffer];
}

- (BOOL) isConnected
{
  return [socket isConnected];
}

- (void) open
{
  [self schedulePollTimer];
  [socket open];
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

- (void) socketIsConnecting: (NSObject <J3Socket> *) possibleSocket
{
  if (![self isUsingSocket: possibleSocket])
    return;
  
  if (delegate && [delegate respondsToSelector: @selector (telnetConnectionIsConnecting:)])
    [delegate telnetConnectionIsConnecting: self];
}

- (void) socketIsConnected: (NSObject <J3Socket> *) possibleSocket
{
  if (![self isUsingSocket: possibleSocket])
    return;
  
  if (delegate && [delegate respondsToSelector: @selector (telnetConnectionIsConnected:)])
    [delegate telnetConnectionIsConnected: self];
}

- (void) socketWasClosedByClient: (NSObject <J3Socket> *) possibleSocket
{
  if (![self isUsingSocket: possibleSocket])
    return;
  
  [self cleanUpPollTimer];
  
  if (delegate && [delegate respondsToSelector: @selector (telnetConnectionWasClosedByClient:)])
    [delegate telnetConnectionWasClosedByClient: self];
}

- (void) socketWasClosedByServer: (NSObject <J3Socket> *) possibleSocket
{
  if (![self isUsingSocket: possibleSocket])
    return;
  
  [self cleanUpPollTimer];
  
  if (delegate && [delegate respondsToSelector: @selector (telnetConnectionWasClosedByServer:)])
    [delegate telnetConnectionWasClosedByServer: self];
}

- (void) socketWasClosed: (NSObject <J3Socket> *) possibleSocket withError: (NSString *) errorMessage
{
  if (![self isUsingSocket: possibleSocket])
    return;
  
  [self cleanUpPollTimer];
  
  if (delegate && [delegate respondsToSelector: @selector (telnetConnectionWasClosed: withError:)])
    [delegate telnetConnectionWasClosed: self withError: errorMessage];
}

@end

#pragma mark -

@implementation J3TelnetConnection (Private)

- (void) cleanUpPollTimer
{
  [pollTimer invalidate];
  pollTimer = nil;
}

- (void) fireTimer: (NSTimer *) timer
{
  [self poll];
}

- (BOOL) isUsingSocket: (NSObject <J3Socket> *) possibleSocket;
{
  return possibleSocket == socket;
}

- (void) poll
{
  // It is possible for the connection to have been released but for there to
  // be a pending timer fire that was registered before the timers were
  // invalidated.
  if (!socket || ![socket isConnected])
    return;
  
  [socket poll];
  if ([socket hasDataAvailable])
    [engine parseData: [socket readUpToLength: TELNET_READ_BUFFER_SIZE]];
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

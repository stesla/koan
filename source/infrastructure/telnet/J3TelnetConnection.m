//
// J3TelnetConnection.m
//
// Copyright (c) 2005, 2006, 2007 3James Software
//

#import "J3ConnectionFactory.h"
#import "J3Socket.h"
#import "J3TelnetConnection.h"

#define TELNET_READ_BUFFER_SIZE 512

#pragma mark -

@interface J3TelnetConnection (Private)

- (void) cleanUpPollTimer;
- (void) fireTimer: (NSTimer *) timer;
- (void) initializeSocket;
- (BOOL) isUsingSocket: (NSObject <J3Socket> *) possibleSocket;
- (void) poll;
- (void) schedulePollTimer;

@end

#pragma mark -

@implementation J3TelnetConnection

- (id) initWithFactory: (J3ConnectionFactory *) factory
              hostname: (NSString *) newHostname
                  port: (int) newPort
                engine: (J3TelnetEngine *) newEngine
              delegate: (NSObject <J3TelnetConnectionDelegate> *) newDelegate;
{
  if (![super init])
    return nil;
  [self at: &connectionFactory put: factory];
  [self at: &hostname put: newHostname];
  port = newPort;
  [self at: &engine put: newEngine];
  [self setDelegate: newDelegate];
  [self at: &outputBuffer put: [J3WriteBuffer buffer]];
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
  [self initializeSocket];
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

#pragma mark -
#pragma mark J3TelnetEngineDelegate

- (void) bufferOutputByte: (uint8_t) byte
{
  [outputBuffer appendByte: byte];
}

- (void) flushOutput
{
  [outputBuffer flush];
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

- (void) initializeSocket
{
  [self at: &socket put: [connectionFactory makeSocketWithHostname: hostname port: port]];
  [socket setDelegate: self];
  [outputBuffer setByteDestination: socket];
}

- (BOOL) isUsingSocket: (NSObject <J3Socket> *) possibleSocket
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

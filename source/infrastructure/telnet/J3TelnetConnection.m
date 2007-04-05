//
// J3TelnetConnection.m
//
// Copyright (c) 2007 3James Software.
//

#import "J3SocketFactory.h"
#import "J3Socket.h"
#import "J3TelnetConnection.h"

#define TELNET_READ_BUFFER_SIZE (size_t) 512

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

+ (id) telnetWithSocketFactory: (J3SocketFactory *) factory
                      hostname: (NSString *) hostname
                          port: (int) port
                      delegate: (NSObject <J3TelnetConnectionDelegate> *) delegate
{
  return [[[self alloc] initWithSocketFactory: factory hostname: hostname port: port delegate: delegate] autorelease];
}

+ (id) telnetWithHostname: (NSString *) hostname
                     port: (int) port
                 delegate: (NSObject <J3TelnetConnectionDelegate> *) delegate
{
  return [self telnetWithSocketFactory: [J3SocketFactory defaultFactory] hostname: hostname port: port delegate: delegate];
}

- (id) initWithSocketFactory: (J3SocketFactory *) factory
                    hostname: (NSString *) newHostname
                        port: (int) newPort
                    delegate: (NSObject <J3TelnetConnectionDelegate> *) newDelegate;
{
  if (![super init])
    return nil;
  [self at: &socketFactory put: factory];
  [self at: &hostname put: newHostname];
  port = newPort;
  [self at: &engine put: [J3TelnetEngine engine]];
  [engine setDelegate: self];
  [self setDelegate: newDelegate];
  [self at: &inputBuffer put: [J3ReadBuffer buffer]];
  [inputBuffer setDelegate: newDelegate];
  [self at: &outputBuffer put: [J3WriteBuffer buffer]];
  pollTimer = nil;
  return self;
}

- (void) dealloc
{
  delegate = nil;
  
  [self close];
  [self cleanUpPollTimer];
  
  [socket release];
  [outputBuffer release];
  [inputBuffer release];
  [engine release];
  [super dealloc];
}

- (void) close
{
  [socket close];
}

- (BOOL) hasInputBuffer: (NSObject <J3ReadBuffer> *) buffer;
{
  return inputBuffer == buffer;
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

- (void) bufferInputByte: (uint8_t) byte;
{
  [inputBuffer appendByte: byte];
}

- (void) writeDataWithPriority: (NSData *) data
{
  [outputBuffer writeDataWithPriority: data];
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
  [self at: &socket put: [socketFactory makeSocketWithHostname: hostname port: port]];
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
    [inputBuffer interpretBufferAsString];
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

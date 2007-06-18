//
// J3TelnetConnection.m
//
// Copyright (c) 2007 3James Software.
//

#import "J3SocketFactory.h"
#import "J3Socket.h"
#import "J3TelnetConnection.h"

@interface J3TelnetConnection (Private)

- (void) cleanUpPollTimer;
- (void) fireTimer: (NSTimer *) timer;
- (void) initializeSocket;
- (BOOL) isUsingSocket: (J3Socket *) possibleSocket;
- (void) poll;
- (void) schedulePollTimer;
- (void) removeNotificationFromDelegate: (NSString *) name selector: (SEL) selector andAddToObject: (id) object;
- (void) writeDataWithPreprocessing: (NSData *) data;

@end

#pragma mark -

@implementation J3TelnetConnection

+ (id) telnetWithSocketFactory: (J3SocketFactory *) factory
                      hostname: (NSString *) hostname
                          port: (int) port
                      delegate: (NSObject <J3ConnectionDelegate> *) delegate
{
  return [[[self alloc] initWithSocketFactory: factory hostname: hostname port: port delegate: delegate] autorelease];
}

+ (id) telnetWithHostname: (NSString *) hostname
                     port: (int) port
                 delegate: (NSObject <J3ConnectionDelegate> *) delegate
{
  return [self telnetWithSocketFactory: [J3SocketFactory defaultFactory] hostname: hostname port: port delegate: delegate];
}

- (id) initWithSocketFactory: (J3SocketFactory *) factory
                    hostname: (NSString *) newHostname
                        port: (int) newPort
                    delegate: (NSObject <J3ConnectionDelegate> *) newDelegate;
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
  pollTimer = nil;
  return self;
}

- (void) dealloc
{
  delegate = nil;
  
  [self close];
  [self cleanUpPollTimer];
  
  [socket release];
  [inputBuffer release];
  [engine release];
  [super dealloc];
}

- (void) close
{
  [socket close];
}

- (BOOL) hasInputBuffer: (NSObject <J3ReadBuffer> *) buffer
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

- (void) setDelegate: (NSObject <J3ConnectionDelegate> *) object
{
  if (delegate == object)
    return;
  
  [self removeNotificationFromDelegate: J3ConnectionDidConnectNotification 
                              selector: @selector(connectionDidConnect:) 
                        andAddToObject: object];
  [self removeNotificationFromDelegate: J3ConnectionIsConnectingNotification 
                              selector: @selector(connectionIsConnecting:) 
                        andAddToObject: object];
  [self removeNotificationFromDelegate: J3ConnectionWasClosedByClientNotification 
                              selector: @selector(connectionWasClosedByClient:) 
                        andAddToObject: object];
  [self removeNotificationFromDelegate: J3ConnectionWasClosedByServerNotification 
                              selector: @selector(connectionWasClosedByServer:) 
                        andAddToObject: object];
  [self removeNotificationFromDelegate: J3ConnectionWasClosedWithErrorNotification 
                              selector: @selector(connectionWasClosedWithError:) 
                        andAddToObject: object];
  
  delegate = object;
}

- (void) writeLine: (NSString *) line
{
  NSString *lineWithLineEnding = [NSString stringWithFormat: @"%@\r\n",line];
  NSData *encodedData = [lineWithLineEnding dataUsingEncoding: NSASCIIStringEncoding allowLossyConversion: YES];
  [self writeDataWithPreprocessing: encodedData];
  [engine goAhead];
}

#pragma mark -
#pragma mark J3ConnectionDelegate protocol

- (void) connectionIsConnecting: (NSNotification *) notification
{
  [[NSNotificationCenter defaultCenter] postNotificationName: J3ConnectionDidConnectNotification
                                                      object: self];
}

- (void) connectionDidConnect: (NSNotification *) notification
{
  [[NSNotificationCenter defaultCenter] postNotificationName: J3ConnectionIsConnectingNotification
                                                      object: self];
}

- (void) connectionWasClosedByClient: (NSNotification *) notification
{
  [self cleanUpPollTimer]; 
  [[NSNotificationCenter defaultCenter] postNotificationName: J3ConnectionWasClosedByClientNotification
                                                      object: self];
}

- (void) connectionWasClosedByServer: (NSNotification *) notification
{
  [self cleanUpPollTimer];
  [[NSNotificationCenter defaultCenter] postNotificationName: J3ConnectionWasClosedByServerNotification
                                                      object: self];
}

- (void) connectionWasClosedWithError: (NSNotification *) notification
{
  [self cleanUpPollTimer];
  [[NSNotificationCenter defaultCenter] postNotificationName: J3ConnectionWasClosedWithErrorNotification
                                                      object: self
                                                    userInfo: [notification userInfo]];
}  

#pragma mark -
#pragma mark J3TelnetEngineDelegate

- (void) bufferInputByte: (uint8_t) byte
{
  [inputBuffer appendByte: byte];
}

- (void) log: (NSString *) message arguments: (va_list) args
{
  NSLog ([[[NSString alloc] initWithFormat: [NSString stringWithFormat: @"[%@:%d] %@", hostname, port, message]
                                 arguments: args] autorelease]);
}

- (void) writeData: (NSData *) data
{
  [socket write: data];
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
}

- (BOOL) isUsingSocket: (J3Socket *) possibleSocket
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
    [engine parseData: [socket readUpToLength: [socket availableBytes]]];
  else
    [inputBuffer interpretBufferAsString];
}

- (void) removeNotificationFromDelegate: (NSString *) name selector: (SEL) selector andAddToObject: (id) object
{
  NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
  [notificationCenter addObserver: object selector: selector name: name object: self];
  [notificationCenter removeObserver: delegate name: name  object: self];
}

- (void) schedulePollTimer
{
  pollTimer = [NSTimer scheduledTimerWithTimeInterval: 0.0
                                               target: self
                                             selector: @selector (fireTimer:)
                                             userInfo: nil
                                              repeats: YES];
}

- (void) writeDataWithPreprocessing: (NSData *) data
{
  [self writeData: [engine preprocessOutput: data]];
}

@end

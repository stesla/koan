//
// J3TelnetConnection.m
//
// Copyright (c) 2010 3James Software.
//

#import "J3SocketFactory.h"
#import "J3Socket.h"
#import "J3TelnetConnection.h"

NSString *J3TelnetConnectionDidConnectNotification = @"J3TelnetConnectionDidConnectNotification";
NSString *J3TelnetConnectionIsConnectingNotification = @"J3TelnetConnectionIsConnectingNotification";
NSString *J3TelnetConnectionWasClosedByClientNotification = @"J3TelnetConnectionWasClosedByClientNotification";
NSString *J3TelnetConnectionWasClosedByServerNotification = @"J3TelnetConnectionWasClosedByServerNotification";
NSString *J3TelnetConnectionWasClosedWithErrorNotification = @"J3TelnetConnectionWasClosedWithErrorNotification";
NSString *J3TelnetConnectionErrorMessageKey = @"J3TelnetConnectionErrorMessageKey";

@interface J3TelnetConnection (Private)

- (void) cleanUpPollTimer;
- (void) fireTimer: (NSTimer *) timer;
- (void) initializeSocket;
- (BOOL) isUsingSocket: (J3Socket *) possibleSocket;
- (void) poll;
- (void) registerObjectForNotifications: (id) object;
- (void) schedulePollTimer;
- (void) unregisterObjectForNotifications: (id) object;
- (void) writeDataWithPreprocessing: (NSData *) data;

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
  if (!(self = [super init]))
    return nil;
  
  [self at: &socketFactory put: factory];
  [self at: &hostname put: newHostname];
  port = newPort;
  [self at: &engine put: [J3TelnetEngine engine]];
  [engine setDelegate: self];
  [self setDelegate: newDelegate];
  [self at: &readBuffer put: [J3ReadBuffer buffer]];
  pollTimer = nil;
  return self;
}

- (void) dealloc
{
  [self unregisterObjectForNotifications: delegate];
  delegate = nil;
  
  [self close];
  [self cleanUpPollTimer];
  
  [socket release];
  [readBuffer release];
  [engine release];
  [super dealloc];
}

- (NSObject <J3TelnetConnectionDelegate> *) delegate
{
  return delegate;
}

- (void) setDelegate: (NSObject <J3TelnetConnectionDelegate> *) object
{
  if (delegate == object)
    return;
  
  [self unregisterObjectForNotifications: delegate];
  [self registerObjectForNotifications: object];
  
  delegate = object;
}

- (void) close
{
  [socket close];
}

- (BOOL) hasReadBuffer: (NSObject <J3ReadBuffer> *) buffer
{
  return readBuffer == buffer;
}

- (void) open
{
  [self initializeSocket];
  [self schedulePollTimer];
  [socket open];
}

- (void) writeLine: (NSString *) line
{
  NSString *lineWithLineEnding = [NSString stringWithFormat: @"%@\r\n",line];
  NSData *encodedData = [lineWithLineEnding dataUsingEncoding: [engine stringEncoding] allowLossyConversion: YES];
  [self writeDataWithPreprocessing: encodedData];
  [engine goAhead];
  [engine endOfRecord];
}

#pragma mark -
#pragma mark J3Connection overrides

- (void) setStatusConnected
{
  [super setStatusConnected];
  [[NSNotificationCenter defaultCenter] postNotificationName: J3TelnetConnectionDidConnectNotification
                                                      object: self];
}

- (void) setStatusConnecting
{
  [super setStatusConnecting];
  [[NSNotificationCenter defaultCenter] postNotificationName: J3TelnetConnectionIsConnectingNotification
                                                      object: self];
}

- (void) setStatusClosedByClient
{
  [super setStatusClosedByClient];
  [[NSNotificationCenter defaultCenter] postNotificationName: J3TelnetConnectionWasClosedByClientNotification
                                                      object: self];
}

- (void) setStatusClosedByServer
{
  [super setStatusClosedByServer];
  [[NSNotificationCenter defaultCenter] postNotificationName: J3TelnetConnectionWasClosedByServerNotification
                                                      object: self];
}

- (void) setStatusClosedWithError: (NSString *) error
{
  [super setStatusClosedWithError: error];
  [[NSNotificationCenter defaultCenter] postNotificationName: J3TelnetConnectionWasClosedWithErrorNotification
                                                      object: self
                                                    userInfo: [NSDictionary dictionaryWithObjectsAndKeys: error, J3TelnetConnectionErrorMessageKey, nil]];
}

#pragma mark -
#pragma mark J3SocketDelegate protocol

- (void) socketIsConnecting: (NSNotification *) notification
{
  [self setStatusConnecting];
}

- (void) socketDidConnect: (NSNotification *) notification
{
  [self setStatusConnected];
}

- (void) socketWasClosedByClient: (NSNotification *) notification
{
  [self cleanUpPollTimer]; 
  [self setStatusClosedByClient];
}

- (void) socketWasClosedByServer: (NSNotification *) notification
{
  [self cleanUpPollTimer];
  [self setStatusClosedByServer];
}

- (void) socketWasClosedWithError: (NSNotification *) notification
{
  [self cleanUpPollTimer];
  [self setStatusClosedWithError: [[notification userInfo] valueForKey: J3SocketErrorMessageKey]];
}

#pragma mark -
#pragma mark J3TelnetEngineDelegate

- (void) bufferInputByte: (uint8_t) byte
{
  [readBuffer appendByte: byte];
}

- (void) consumeReadBufferAsSubnegotiation
{
  [engine handleIncomingSubnegotiation: [readBuffer dataByConsumingBuffer]];
}

- (void) consumeReadBufferAsText
{
  [delegate displayString: [readBuffer stringByConsumingBufferWithEncoding: [engine stringEncoding]]];
}

- (void) log: (NSString *) message arguments: (va_list) args
{
  NSLog (@"[%@:%d] %@", hostname, port, [[[NSString alloc] initWithFormat: message arguments: args] autorelease]);
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
    [self consumeReadBufferAsText];
}

- (void) registerObjectForNotifications: (id) object
{
  NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
  
  [notificationCenter addObserver: object
                         selector: @selector(telnetConnectionDidConnect:)
                             name: J3TelnetConnectionDidConnectNotification
                           object: self];
  [notificationCenter addObserver: object
                         selector: @selector(telnetConnectionIsConnecting:)
                             name: J3TelnetConnectionIsConnectingNotification
                           object: self];
  [notificationCenter addObserver: object
                         selector: @selector(telnetConnectionWasClosedByClient:)
                             name: J3TelnetConnectionWasClosedByClientNotification
                           object: self];
  [notificationCenter addObserver: object
                         selector: @selector(telnetConnectionWasClosedByServer:)
                             name: J3TelnetConnectionWasClosedByServerNotification
                           object: self];
  [notificationCenter addObserver: object
                         selector: @selector(telnetConnectionWasClosedWithError:)
                             name: J3TelnetConnectionWasClosedWithErrorNotification
                           object: self];
}

- (void) schedulePollTimer
{
  pollTimer = [NSTimer scheduledTimerWithTimeInterval: 0.05
                                               target: self
                                             selector: @selector (fireTimer:)
                                             userInfo: nil
                                              repeats: YES];
}

- (void) unregisterObjectForNotifications: (id) object
{
  NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
  
  [notificationCenter removeObserver: object name: J3SocketDidConnectNotification object: self];
  [notificationCenter removeObserver: object name: J3SocketIsConnectingNotification object: self];
  [notificationCenter removeObserver: object name: J3SocketWasClosedByClientNotification object: self];
  [notificationCenter removeObserver: object name: J3SocketWasClosedByServerNotification object: self];
  [notificationCenter removeObserver: object name: J3SocketWasClosedWithErrorNotification object: self];
}

- (void) writeDataWithPreprocessing: (NSData *) data
{
  [self writeData: [engine preprocessOutput: data]];
}

@end

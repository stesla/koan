//
// J3TelnetConnection.m
//
// Copyright (c) 2010 3James Software.
//

#import "J3SocketFactory.h"
#import "J3Socket.h"
#import "J3TelnetConnection.h"
#import "J3TelnetProtocolHandler.h"
#import "MUMCCPProtocolHandler.h"

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

@synthesize socket, state;

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
  
  state = [[J3TelnetConnectionState connectionState] retain];
  socketFactory = [factory retain];
  hostname = [newHostname copy];
  port = newPort;
  pollTimer = nil;
  
  protocolStack = [[J3ProtocolStack alloc] init];
  
  J3TelnetProtocolHandler *telnetProtocolHandler = [J3TelnetProtocolHandler protocolHandlerWithStack: protocolStack connectionState: state];
  [telnetProtocolHandler setDelegate: self];
  [protocolStack addByteProtocol: telnetProtocolHandler];
  
  MUMCCPProtocolHandler *mccpProtocolHandler = [MUMCCPProtocolHandler protocolHandlerWithStack: protocolStack connectionState: state];
  [mccpProtocolHandler setDelegate: self];
  [protocolStack addByteProtocol: mccpProtocolHandler];
  
  self.delegate = newDelegate;
  return self;
}

- (void) dealloc
{
  self.delegate = nil;
  
  [self close];
  [self cleanUpPollTimer];
  
  [socketFactory release];
  [socket release];
  [hostname release];
  [protocolStack release];
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

- (void) log: (NSString *) message, ...
{
  va_list args;
  va_start (args, message);
  
  [self log: message arguments: args];
  
  va_end (args);
}

- (void) writeLine: (NSString *) line
{
  NSString *lineWithLineEnding = [NSString stringWithFormat: @"%@\r\n",line];
  NSData *encodedData = [lineWithLineEnding dataUsingEncoding: [self.state stringEncoding] allowLossyConversion: YES];
  [self writeDataWithPreprocessing: encodedData];
}

#pragma mark -
#pragma mark J3Connection overrides

- (void) close
{
  [self.socket close];
}

- (void) open
{
  [self initializeSocket];
  [self schedulePollTimer];
  [self.socket open];
}

- (void) setStatusConnected
{
  [super setStatusConnected];
  [self log: @"Connected to server."];
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
  [self log: @"Connection closed by client."];
  [[NSNotificationCenter defaultCenter] postNotificationName: J3TelnetConnectionWasClosedByClientNotification
                                                      object: self];
}

- (void) setStatusClosedByServer
{
  [super setStatusClosedByServer];
  [self log: @"Connection closed by server."];
  [[NSNotificationCenter defaultCenter] postNotificationName: J3TelnetConnectionWasClosedByServerNotification
                                                      object: self];
}

- (void) setStatusClosedWithError: (NSString *) error
{
  [super setStatusClosedWithError: error];
  [self log: @"Connection closed with error: %@.", error];
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
#pragma mark Various delegates

- (void) log: (NSString *) message arguments: (va_list) args
{
  NSLog (@"[%@:%d] %@", hostname, port, [[[NSString alloc] initWithFormat: message arguments: args] autorelease]);
}

#pragma mark -
#pragma mark J3TelnetProtocolHandlerDelegate

- (void) writeDataToSocket: (NSData *) data
{
  [self.socket write: data];
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
  self.socket = [socketFactory makeSocketWithHostname: hostname port: port];
  self.socket.delegate = self;
}

- (BOOL) isUsingSocket: (J3Socket *) possibleSocket
{
  return possibleSocket == self.socket;
}

- (void) poll
{
  // It is possible for the connection to have been released but for there to
  // be a pending timer fire that was registered before the timers were
  // invalidated.
  if (!self.socket || ![self.socket isConnected])
    return;
  
  [self.socket poll];
  
  if ([self.socket hasDataAvailable])
  {
    NSData *parsedData = [protocolStack parseData: [self.socket readUpToLength: [self.socket availableBytes]]];
    NSString *parsedString = [[[NSString alloc] initWithBytes: [parsedData bytes] length: [parsedData length] encoding: [self.state stringEncoding]] autorelease];
    
    [self.delegate displayString: parsedString];
  }
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
  [self writeDataToSocket: [protocolStack preprocessOutput: data]];
}

@end

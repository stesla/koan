//
// J3Socket.m
//
// Copyright (c) 2005, 2006 3James Software
//

#import "J3Socket.h"

#import <sys/ioctl.h>
#import <sys/socket.h>
#import <errno.h>
#import <netdb.h>
#import <unistd.h>

@interface J3Socket (Private)

- (void) checkRemoteConnection;
- (void) configureSocket;
- (void) connectSocket;
- (void) createSocket;
- (void) handleReadWriteError;
- (void) initializeDescriptorSet: (fd_set *)set;
- (void) performPostConnectNegotiation;
- (void) resolveHostname;
- (void) setStatusConnected;
- (void) setStatusConnecting;
- (void) setStatusClosedByClient;
- (void) setStatusClosedByServer;
- (void) setStatusClosedWithError: (NSString *)error;

@end

#pragma mark -

@implementation J3SocketException

+ (void) socketError: (NSString *)errorMessage
{
  @throw [J3SocketException exceptionWithName: @"" reason: errorMessage userInfo: nil];
}

+ (void) socketErrorFormat: (NSString *)format arguments: (va_list)args
{
  NSString *message = [[[NSString alloc] initWithFormat: format arguments: args] autorelease];
  [self socketError: message];
}

+ (void) socketErrorWithErrno;
{
  [J3SocketException socketError: [NSString stringWithCString: strerror (errno)]];
}

@end

#pragma mark -

@implementation J3Socket

+ (id) socketWithHostname: (NSString *)hostname port: (int)port
{
  return [[[self alloc] initWithHostname: hostname port: port] autorelease];
}

- (id) initWithHostname: (NSString *)newHostname port: (int)newPort
{
  if (![super init])
    return nil;
  hostname = [newHostname retain];
  port = newPort;
  status = J3SocketStatusNotConnected;
  return self;
}

- (void) dealloc
{
  delegate = nil;
  [hostname release];
  [super dealloc];
}

- (void) close
{
  if (![self isConnected])
    return;
  close(socketfd);
  [self setStatusClosedByClient];    
}

- (BOOL) hasDataAvailable
{
  return hasDataAvailable; 
}

- (BOOL) hasSpaceAvailable
{
  return YES; 
}

- (BOOL) isClosed
{
  return status == J3SocketStatusClosed;
}

- (BOOL) isConnected
{
  return status == J3SocketStatusConnected;
}

- (BOOL) isConnecting
{
  return status == J3SocketStatusConnecting;
}

- (void) open
{  
  if ([self isConnected] || [self isConnecting] || [self isClosed])
    return;
  @try
  {
    [self setStatusConnecting];
    [self resolveHostname];
    [self createSocket];
    [self configureSocket];
    [self connectSocket];
    [self performPostConnectNegotiation];
    [self setStatusConnected];    
  }
  @catch(J3SocketException *socketException)
  {
    [self setStatusClosedWithError: [socketException reason]];
  }
}

- (void) poll
{
  fd_set read_set;
  struct timeval tval;
  int result;
  
  hasDataAvailable = NO;
  
  memset (&tval, 0, sizeof (struct timeval));
  tval.tv_usec = 100;
  
  [self initializeDescriptorSet: &read_set];
  errno = 0;
  
  result = select (socketfd + 1, &read_set, NULL, NULL, &tval);  
  
  if (result < 0)
    [J3SocketException socketErrorWithErrno];
  
  if (FD_ISSET (socketfd, &read_set))
  {
    hasDataAvailable = YES;
    [self checkRemoteConnection];
  }
}

- (unsigned) read: (uint8_t *)bytes maxLength: (unsigned)length
{
  int result;
  errno = 0;
  result = read (socketfd, bytes, length);
  if (result < 0)
    [self handleReadWriteError];
  return result;
}

- (void) setDelegate: (NSObject <J3ConnectionDelegate> *)object
{
  [self at: &delegate put: object];
}

- (J3SocketStatus) status
{
  return status;
}

#pragma mark -
#pragma mark J3ByteDestination protocol

- (unsigned) write: (const uint8_t *)bytes length: (unsigned)length
{
  int result;
  errno = 0;
  result = write (socketfd, bytes, length);
  if (result < 0)
    [self handleReadWriteError];
  return result;
}

@end

#pragma mark -

@implementation J3Socket (Private)

- (void) checkRemoteConnection
{
  char *nread;
  int result = ioctl (socketfd, FIONREAD, &nread);
  
  if (result < 0)
  {
    hasDataAvailable = NO;
    [J3SocketException socketErrorWithErrno];
  }
  if (!nread)
  {
    close (socketfd);
    hasDataAvailable = NO;
    [self setStatusClosedByServer];
  }
}

- (void) configureSocket
{
  server_addr.sin_family = AF_INET;
  server_addr.sin_port = htons (port);
  memcpy (&(server_addr.sin_addr.s_addr), server->h_addr, server->h_length);    
}

- (void) connectSocket
{
  int result;
  errno = 0;
  result = connect (socketfd, (struct sockaddr *) &server_addr, sizeof (struct sockaddr));
  if (result < 0)
    [J3SocketException socketErrorWithErrno];
}

- (void) createSocket
{  
  errno = 0;
  socketfd = socket (AF_INET, SOCK_STREAM, 0);
  if (socketfd < 0)
    [J3SocketException socketErrorWithErrno];
}

- (void) handleReadWriteError;
{
  if (![self isConnected] && ![self isConnecting])
    return;
  if ((errno == EBADF) || (errno == EPIPE))
    [self setStatusClosedByServer];
  [J3SocketException socketErrorWithErrno];
}

- (void) initializeDescriptorSet: (fd_set *)set
{
  FD_ZERO (set);
  FD_SET (socketfd, set);
}

- (void) performPostConnectNegotiation;
{
  // Override in subclass to do something after connecting but before changing status
}

- (void) resolveHostname
{
  h_errno = 0;
  const char *error;
  server = gethostbyname ([hostname cString]);
  if (!server)
  {
    error = hstrerror (h_errno);
    [J3SocketException socketError: [NSString stringWithFormat: @"%s", error]];
  }
}

- (void) setStatusConnected
{
  status = J3SocketStatusConnected;
  if (delegate && [delegate respondsToSelector: @selector (connectionIsConnected:)])
    [delegate connectionIsConnected: self];
}

- (void) setStatusConnecting
{
  status = J3SocketStatusConnecting;
  if (delegate && [delegate respondsToSelector: @selector (connectionIsConnecting:)])
    [delegate connectionIsConnecting: self];
}

- (void) setStatusClosedByClient
{
  status = J3SocketStatusClosed;
  if (delegate && [delegate respondsToSelector: @selector (connectionWasClosedByClient:)])
    [delegate connectionWasClosedByClient: self];
}

- (void) setStatusClosedByServer
{
  status = J3SocketStatusClosed;
  if (delegate && [delegate respondsToSelector: @selector (connectionWasClosedByServer:)])
    [delegate connectionWasClosedByServer: self];
}

- (void) setStatusClosedWithError: (NSString *)error
{
  status = J3SocketStatusClosed;
  if (delegate && [delegate respondsToSelector: @selector (connectionWasClosed:withError:)])
    [delegate connectionWasClosed: self withError: error];
}
@end

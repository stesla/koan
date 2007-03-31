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
- (void) initializeDescriptorSet: (fd_set *) set;
- (void) performPostConnectNegotiation;
- (void) resolveHostname;
- (void) setStatusConnected;
- (void) setStatusConnecting;
- (void) setStatusClosedByClient;
- (void) setStatusClosedByServer;
- (void) setStatusClosedWithError: (NSString *) error;

@end

#pragma mark -

@implementation J3SocketException

+ (void) socketError: (NSString *) errorMessage
{
  @throw [J3SocketException exceptionWithName: @"" reason: errorMessage userInfo: nil];
}

+ (void) socketErrorFormat: (NSString *) format arguments: (va_list)args
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

+ (id) socketWithHostname: (NSString *) hostname port: (int) port
{
  return [[[self alloc] initWithHostname: hostname port: port] autorelease];
}

- (id) initWithHostname: (NSString *) newHostname port: (int) newPort
{
  if (![super init])
    return nil;
  
  [self at: &hostname put: [newHostname retain]];
  port = newPort;
  status = J3SocketStatusNotConnected;
  server = NULL;
  
  return self;
}

- (void) dealloc
{
  delegate = nil;
  [hostname release];
  
  if (server)
    free (server);
  
  [super dealloc];
}

- (void) close
{
  if (![self isConnected])
    return;
  
  close (socketfd);
  socketfd = -1;
  [self setStatusClosedByClient];    
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
  if ([self isConnected] || [self isConnecting])
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
  @catch (J3SocketException *socketException)
  {
    [self setStatusClosedWithError: [socketException reason]];
  }
}

- (void) poll
{
  hasDataAvailable = NO;
  
  fd_set read_set;
  struct timeval tval;
  
  memset (&tval, 0, sizeof (struct timeval));
  tval.tv_usec = 100;
  
  [self initializeDescriptorSet: &read_set];
  errno = 0;
  
  int result = select (socketfd + 1, &read_set, NULL, NULL, &tval);  
  
  if (result < 0)
    [J3SocketException socketErrorWithErrno];
  
  if (FD_ISSET (socketfd, &read_set))
  {
    hasDataAvailable = YES;
    [self checkRemoteConnection];
  }
}

- (void) setDelegate: (NSObject <J3ConnectionDelegate> *) object
{
  delegate = object;
}

- (J3SocketStatus) status
{
  return status;
}

#pragma mark -
#pragma mark J3ByteSource protocol

- (BOOL) hasDataAvailable
{
  return hasDataAvailable;
}

- (NSData *) readUpToLength: (unsigned) length
{
  uint8_t *bytes = malloc (length);
  if (!bytes)
  {
    @throw [NSException exceptionWithName: NSMallocException reason: @"Could not allocate socket read buffer" userInfo: nil];
  }

  errno = 0;
  ssize_t bytesRead = read (socketfd, bytes, length);
  
  if (bytesRead < 0)
  {
    free (bytes);
    [self handleReadWriteError];
  }
  
  return [NSData dataWithBytesNoCopy: bytes length: bytesRead];
}

#pragma mark -
#pragma mark J3ByteDestination protocol

- (BOOL) hasSpaceAvailable
{
  return YES;
}

- (unsigned) write: (NSData *) data
{
  ssize_t result;
  errno = 0;
  result = write (socketfd, [data bytes], [data length]);
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
  errno = 0;
  int result = connect (socketfd, (struct sockaddr *) &server_addr, sizeof (struct sockaddr));
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
  if (errno == EBADF || errno == EPIPE)
    [self setStatusClosedByServer];
  
  [J3SocketException socketErrorWithErrno];
}

- (void) initializeDescriptorSet: (fd_set *) set
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
  
  if (server)
    return;
  
  server = malloc (sizeof (struct hostent));
  if (!server)
    @throw [NSException exceptionWithName: NSMallocException reason: @"Could not allocate struct hostent for socket" userInfo: nil];
  
  @synchronized ([self class])
  {
    struct hostent *hostent = gethostbyname ([hostname cString]);
    
    if (hostent)
      memcpy (server, hostent, sizeof (struct hostent));
    else
    {
      free (server);
      server = NULL;
      const char *error = hstrerror (h_errno);
      [J3SocketException socketError: [NSString stringWithFormat: @"%s", error]];
    }
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

- (void) setStatusClosedWithError: (NSString *) error
{
  status = J3SocketStatusClosed;
  if (delegate && [delegate respondsToSelector: @selector (connectionWasClosed:withError:)])
    [delegate connectionWasClosed: self withError: error];
}

@end

//
// J3Socket.m
//
// Copyright (c) 2007 3James Software.
//

#import "J3Socket.h"

#include <errno.h>
#include <netdb.h>
#include <poll.h>
#include <stdarg.h>
#include <sys/event.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <unistd.h>

#include "J3Connection.h"

#pragma mark -
#pragma mark C Function Prototypes

static inline ssize_t full_write (int file_descriptor, const void *bytes, size_t length);
static inline ssize_t safe_read (int file_descriptor, void *bytes, size_t length);
static inline ssize_t safe_write (int file_descriptor, const void *bytes, size_t length);

#pragma mark -

@interface J3Socket (PrivateRunsInThread)

- (void) connectSocket;
- (void) createSocket;
- (void) initializeKernelQueue;
- (void) internalClose;
- (void) internalOpen;
- (void) internalRead;
- (void) internalWrite;
- (void) performPostConnectNegotiation;
- (void) resolveHostname;
- (void) runThread: (id) object;

@end

#pragma mark -

@implementation J3SocketException

+ (void) socketError: (NSString *) errorMessage
{
  @throw [J3SocketException exceptionWithName: @"" reason: errorMessage userInfo: nil];
}

+ (void) socketErrorWithFormat: (NSString *) format, ...
{
  va_list args;
  va_start (args, format);
  
  NSString *message = [[[NSString alloc] initWithFormat: format arguments: args] autorelease];
  
  va_end (args);
  
  [self socketError: message];
}

+ (void) socketErrorWithErrnoForFunction: (NSString *) functionName;
{
  [J3SocketException socketError: [NSString stringWithFormat: @"%@: %s", functionName, strerror (errno)]];
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
  socketfd = -1;
  port = newPort;
  server = NULL;
  dataToWrite = [[NSMutableArray alloc] init];
  dataToWriteLock = [[NSObject alloc] init];
  availableBytesLock = [[NSObject alloc] init];
  
  return self;
}

- (void) dealloc
{
  [self close];
  
  [availableBytesLock release];
  [dataToWriteLock release];
  [dataToWrite release];
  delegate = nil;
  [hostname release];
 
  if (server)
    free (server);
  
  [super dealloc];
}

- (void) close
{
  [self internalClose];
}

- (void) open
{
  [NSThread detachNewThreadSelector: @selector (runThread:) toTarget: self withObject: nil];
}

#pragma mark -
#pragma mark J3ByteSource protocol

- (unsigned) availableBytes
{
  return availableBytes;
}

- (BOOL) hasDataAvailable
{
  return availableBytes > 0;
}

- (void) poll
{
  [self internalWrite];
  [self internalRead];
}

- (NSData *) readExactlyLength: (size_t) length
{
  while (([self isConnected] || [self isConnecting])
         && availableBytes < length)
    [self poll];
  
  return [self readUpToLength: length];
}

- (NSData *) readUpToLength: (size_t) length
{
  uint8_t *bytes = malloc (length);
  if (!bytes)
  {
    @throw [NSException exceptionWithName: NSMallocException reason: @"Could not allocate socket read buffer" userInfo: nil];
  }

  errno = 0;
  
  ssize_t bytesRead = safe_read (socketfd, bytes, length);
    
  if (bytesRead == -1)
  {
    free (bytes);
    
    // TODO: is this correct?
    if (!([self isConnected] || [self isConnecting]))
      return nil;
    
    if (errno == EBADF || errno == EPIPE)
      [self performSelectorOnMainThread: @selector(setStatusClosedByServer) withObject: nil waitUntilDone: YES];
    
    [J3SocketException socketErrorWithErrnoForFunction: @"read"];
  }
  
  @synchronized (availableBytesLock)
  {
    availableBytes -= bytesRead;
  }
  
  return [NSData dataWithBytesNoCopy: bytes length: bytesRead];
}

#pragma mark -
#pragma mark J3ByteDestination protocol

- (void) write: (NSData *) data
{
  @synchronized (dataToWriteLock)
  {
    [dataToWrite insertObject: data atIndex: 0];
  }
}

@end

#pragma mark -

@implementation J3Socket (PrivateRunsInThread)

- (void) connectSocket
{
  errno = 0;
  availableBytes = 0;
  
  struct sockaddr_in server_address;
  
  server_address.sin_family = AF_INET;
  server_address.sin_port = htons (port);
  memcpy (&server_address.sin_addr.s_addr, server->h_addr, server->h_length);   
  
  if (connect (socketfd, (struct sockaddr *) &server_address, sizeof (struct sockaddr)) == -1)
  {
    if (errno != EINTR)
    {
      [J3SocketException socketErrorWithErrnoForFunction: @"connect"];
      return;
    }
    
    struct pollfd socket_status;
    socket_status.fd = socketfd;
    socket_status.events = POLLOUT;
    
    while (poll (&socket_status, 1, -1) == -1)
    {
      if (errno != EINTR)
      {
        [J3SocketException socketErrorWithErrnoForFunction: @"poll"];
        return;
      }
    }
    
    int connect_error;
    socklen_t connect_error_length = sizeof (connect_error);
    
    if (getsockopt (socketfd, SOL_SOCKET, SO_ERROR, &connect_error, &connect_error_length) == -1)
    {
      [J3SocketException socketErrorWithErrnoForFunction: @"getsockopt"];
      return;
    }
    
    if (connect_error != 0)
    {
      [J3SocketException socketError: [NSString stringWithFormat: @"delayed connect: %s", strerror (connect_error)]];
      return;
    }
    
    // If we reach this point, the socket has successfully connected. =p
  }
  
  [self initializeKernelQueue];
}

- (void) createSocket
{  
  errno = 0;
  socketfd = socket (AF_INET, SOCK_STREAM, 0);
  if (socketfd == -1)
    [J3SocketException socketErrorWithErrnoForFunction: @"socket"];
}

- (void) initializeKernelQueue
{
  errno = 0;
  kq = kqueue ();
  if (kq == -1)
    [J3SocketException socketErrorWithErrnoForFunction: @"kqueue"];
  
  struct kevent socket_event;
  
  EV_SET (&socket_event, socketfd, EVFILT_READ, EV_ADD, 0, 0, 0);
  
  int result;
  do
  {
    result = kevent (kq, &socket_event, 1, NULL, 0, NULL);
  }
  while (result == -1 && errno == EINTR);
  
  if (result == -1)
    [J3SocketException socketErrorWithErrnoForFunction: @"kevent"];
}

- (void) internalClose
{
  if (![self isConnected])
    return;
  
  errno = 0;
  
  // Note that looping on EINTR is specifically wrong for close(2), since the
  // underlying fd will be closed either way; EINTR here tends to indicate that
  // a final flush was interrupted and we may have lost data.
  /* int result = */ close (socketfd);
  socketfd = -1;
  [self performSelectorOnMainThread: @selector(setStatusClosedByClient) withObject: nil waitUntilDone: YES];
  
  /* int result = */ close (kq);
  
  // TODO: handle result == -1 in some way. We could throw an exception, return
  // it up from here, but it should be noted and handled.
}  

- (void) internalOpen
{
  if ([self isConnected] || [self isConnecting])
    return;
  
  @try
  {
    [self performSelectorOnMainThread: @selector(setStatusConnecting) withObject: nil waitUntilDone: YES];
    [self resolveHostname];
    [self createSocket];
    [self connectSocket];
    [self performPostConnectNegotiation];
    [self performSelectorOnMainThread: @selector(setStatusConnected) withObject: nil waitUntilDone: YES];
  }
  @catch (J3SocketException *socketException)
  {
    [self performSelectorOnMainThread: @selector(setStatusClosedWithError:) withObject: [socketException reason] waitUntilDone: YES];
  }
}

- (void) internalRead
{
  struct timespec timeout = {0, 0};
  struct kevent triggered_event;
  errno = 0;
  
  int result;
  
  do
  {
    result = kevent (kq, NULL, 0, &triggered_event, 1, &timeout);
  }
  while (result == -1 && errno == EINTR);
  
  if (result == -1)
    [J3SocketException socketErrorWithErrnoForFunction: @"kevent"];
  
  if (result == 0)
    return;
  
  if (triggered_event.flags & EV_EOF)
  {
    [self performSelectorOnMainThread: @selector(setStatusClosedByServer) withObject: nil waitUntilDone: YES];
    return;
  }
  
  if ((int) triggered_event.ident == socketfd
      && triggered_event.data > 0)
  {
    @synchronized (availableBytesLock)
    {
      availableBytes += triggered_event.data;
    }
  }
}

- (void) internalWrite
{
  NSData *data;
  @synchronized (dataToWriteLock)
  {
    data = [[dataToWrite lastObject] retain];
    if (data == nil)
      return;    
    [dataToWrite removeLastObject];
  }
    
  errno = 0; 
  ssize_t bytes_written = full_write (socketfd, [data bytes], (size_t) [data length]);
  [data release];
  
  if (bytes_written == -1)
  {
    // TODO: is this correct?
    if (!([self isConnected] || [self isConnecting]))
      return;
    
    if (errno == EBADF || errno == EPIPE)
      [self performSelectorOnMainThread: @selector(setStatusClosedByServer) withObject: nil waitUntilDone: YES];
    
    [J3SocketException socketErrorWithErrnoForFunction: @"write"];
  }

}

- (void) performPostConnectNegotiation
{
  // Override in subclass to do something after connecting but before changing status
}

- (void) resolveHostname
{
  if (server)
    return;
  
  server = malloc (sizeof (struct hostent));
  if (!server)
    @throw [NSException exceptionWithName: NSMallocException reason: @"Could not allocate struct hostent for socket" userInfo: nil];
  
  @synchronized ([self class])
  {
    h_errno = 0;
    
    struct hostent *hostent = gethostbyname ([hostname cString]);
    
    if (hostent)
      memcpy (server, hostent, sizeof (struct hostent));
    else
    {
      free (server);
      server = NULL;
      [J3SocketException socketErrorWithFormat: @"%s", hstrerror (h_errno)];
    }
  }
}

- (void) runThread: (id) object
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  @try
  {
    [self internalOpen];
  }
  @finally
  {
    [pool release];
  }
}

@end

#pragma mark -
#pragma mark C Functions

static inline ssize_t
full_write (int file_descriptor, const void *bytes, size_t length)
{
  ssize_t bytes_written;
  ssize_t total_bytes_written = 0;
  
  while (length > 0)
  {
    bytes_written = safe_write (file_descriptor, bytes, length);
    if (bytes_written == -1)
      return bytes_written;
    total_bytes_written += bytes_written;
    bytes = (const uint8_t *) bytes + bytes_written;
    length -= bytes_written;
  }
  
  return total_bytes_written;
}

static inline ssize_t
safe_read (int file_descriptor, void *bytes, size_t length)
{
  ssize_t bytes_read;
  do
  {
    bytes_read = read (file_descriptor, bytes, length);
  }
  while (bytes_read == -1 && errno == EINTR);
  return bytes_read;
}

static inline ssize_t
safe_write (int file_descriptor, const void *bytes, size_t length)
{
  ssize_t bytes_written;
  do
  {
    bytes_written = write (file_descriptor, bytes, length);
  }
  while (bytes_written == -1 && errno == EINTR);  
  return bytes_written;  
}


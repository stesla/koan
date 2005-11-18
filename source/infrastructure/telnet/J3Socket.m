//
//  J3Socket.m
//  NewTelnet
//
//  Created by Samuel Tesla on 11/10/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "J3Socket.h"

#import <sys/ioctl.h>
#import <sys/socket.h>
#import <errno.h>
#import <netdb.h>
#import <unistd.h>

@interface J3Socket (Private)

- (void) resolveHostname;
- (void) checkRemoteConnection;
- (void) createSocket;
- (void) configureSocket;
- (void) connectSocket;
- (void) initializeDescriptorSet:(fd_set *)set;
- (void) setStatusConnecting;
- (void) setStatusConnected;
- (void) setStatusClosedByClient;
- (void) setStatusClosedByServer;
- (void) setStatusClosedWithError:(NSString *)error;
- (void) socketError:(NSString *)errorMessage;
- (void) socketErrorFormat:(NSString *)format arguments:(va_list)args;

@end

#pragma mark -

@implementation J3SocketException

@end

#pragma mark -

@implementation J3Socket

+ (id) socketWithHostname:(NSString *)hostname port:(int)port;
{
  return [[[self alloc] initWithHostname:hostname port:port] autorelease];
}

- (BOOL) hasDataAvailable;
{
  return hasDataAvailable; 
}

- (BOOL) hasSpaceAvailable;
{
  return hasSpaceAvailable; 
}

- (id) initWithHostname:(NSString *)newHostname port:(int)newPort;
{
  if (![super init])
    return nil;
  hostname = [newHostname retain];
  port = newPort;
  status = J3SocketStatusNotConnected;
  return self;
}

- (BOOL) isClosed;
{
  return status == J3SocketStatusClosed;
}

- (BOOL) isConnected;
{
  return status == J3SocketStatusConnected;
}

- (void) open;
{  
  if ([self isConnected] || [self isClosed])
    return; //TODO: @throw here?
  @try
  {
    [self setStatusConnecting];
    [self resolveHostname];
    [self createSocket];
    [self configureSocket];
    [self connectSocket];
    [self setStatusConnected];    
  }
  @catch(J3SocketException *socketException)
  {
    [self setStatusClosedWithError:[socketException reason]];
  }
}

- (void) close;
{
  if (![self isConnected])
    return; //TODO: @throw here?
  close(socketfd);
  [self setStatusClosedByClient];    
}

- (unsigned int) read:(uint8_t *)bytes maxLength:(unsigned int)length;
{
  //TODO: Handle error condition (returns -1)
  return read (socketfd, bytes, length);
}

- (unsigned int) writeBytes:(const uint8_t *)bytes length:(unsigned int)length;
{
  //TODO: Handle error condition (returns -1)
  return write (socketfd, bytes, length);
}

- (void) poll;
{
  fd_set read_set;
  fd_set write_set;
  struct timeval tv;
  int result;
  
  hasDataAvailable = NO;
  hasSpaceAvailable = NO;
  
  [self initializeDescriptorSet:&read_set];
  [self initializeDescriptorSet:&write_set];
  memset (&tv, 0, sizeof (struct timeval));
  errno = 0;
  
  result = select (socketfd + 1, &read_set, &write_set, NULL, &tv);  
  
  if (result < 0)
    return; // TODO: error, should probably do something more drastic...
  
  if (FD_ISSET (socketfd, &read_set))
  {
    [self checkRemoteConnection];
    hasDataAvailable = YES;    
  }
  if (FD_ISSET (socketfd, &write_set))
    hasSpaceAvailable = YES;    
}

- (void) setDelegate:(id <NSObject, J3SocketDelegate>)object;
{
  [self at:&delegate put:object];
}

- (J3SocketStatus) status;
{
  return status;
}

@end

#pragma mark -

@implementation J3Socket (Private)

- (void) resolveHostname;
{
  h_errno = 0;
  const char *error;
	server = gethostbyname ([hostname cString]);
  if (!server)
  {
    error = hstrerror (h_errno);
    [self socketError:[NSString stringWithFormat:@"%s", error]];
  }
}

- (void) createSocket;
{  
  errno = 0;
  socketfd = socket (AF_INET, SOCK_STREAM, 0);
  if (socketfd < 0)
    [self socketErrorFormat:@"%s" arguments:strerror (errno)];
}

- (void) checkRemoteConnection;
{
  char *nread;
  int result = ioctl (socketfd, FIONREAD, &nread);
  
  if (result < 0)
    ; //TODO: handle error
  if (!nread)
  {
    close (socketfd);
    [self setStatusClosedByServer];
  }
}

- (void) configureSocket;
{
  server_addr.sin_family = AF_INET;
	server_addr.sin_port = htons (port);
	memcpy (&(server_addr.sin_addr.s_addr), server->h_addr, server->h_length);    
}

- (void) connectSocket;
{
  int result;
  errno = 0;
  result = connect (socketfd, (struct sockaddr *) &server_addr, sizeof (struct sockaddr));
  if (result < 0)
    [self socketErrorFormat:@"%s" arguments:strerror (errno)];
}

- (void) initializeDescriptorSet:(fd_set *)set;
{
  FD_ZERO (set);
  FD_SET (socketfd, set);
}

- (void) setStatusConnecting;
{
  status = J3SocketStatusConnecting;
  if (delegate)
    [delegate socketIsConnecting:self];
}

- (void) setStatusConnected;
{
  status = J3SocketStatusConnected;
  if (delegate)
    [delegate socketIsConnected:self];
}

- (void) setStatusClosedByClient;
{
  status = J3SocketStatusClosed;
  if (delegate)
    [delegate socketIsClosedByClient:self];
}

- (void) setStatusClosedByServer;
{
  status = J3SocketStatusClosed;
  if (delegate)
    [delegate socketIsClosedByServer:self];
}

- (void) setStatusClosedWithError:(NSString *)error;
{
  status = J3SocketStatusClosed;
  if (delegate)
    [delegate socketIsClosed:self withError:error];
}

- (void) socketError:(NSString *)errorMessage;
{
  @throw [J3SocketException exceptionWithName:@"" reason:errorMessage userInfo:nil];
}

- (void) socketErrorFormat:(NSString *)format arguments:(va_list)args;
{
  NSString *message = [[[NSString alloc] initWithFormat:format arguments:args] autorelease];
  [self socketError:message];
}
@end

//
//  MUSocketConnection.m
//
// Copyright (C) 2004 Tyler Berry and Samuel Tesla
//
// Koan is free software; you can redistribute it and/or modify it under the
// terms of the GNU General Public License as published by the Free Software
// Foundation; either version 2 of the License, or (at your option) any later
// version.
//
// Koan is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// Koan; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
// Suite 330, Boston, MA 02111-1307 USA
//

#import "MUSocketConnection.h"

@implementation MUSocketConnection

void *
_mu_malloc (int count)
{
  void *result;
  if ((result = malloc (count)) == NULL)
  {
    NSLog (@"Error Allocating Memory");
  }
  return result;
}

+ (id) socketWithHost:(NSString *)host port:(short)port
{
  return [[[MUSocketConnection alloc] initWithHost:host port:port] autorelease];
}

- (id) initWithHost:(NSString *)host port:(short)port
{
  if (self = [super init])
  {
    _bufferSize = 512;
    _socket = -1;
    [self setHost:host];
    [self setPort:port];
  }
  return self;
}

- (id) init
{
  return [self initWithHost:nil port:-1];
}

- (int) bufferSize
{
  return _bufferSize;
}

- (void) close 
{
  if ([self isConnected])
  {
    close (_socket);
    _socket = -1;
  }
}

- (id) delegate 
{
	return _delegate;
}

- (void) didReadData:(NSData *)data
{
  if ([[self delegate] respondsToSelector:@selector(socket:didReadData:)])
  {
    [[self delegate] socket:self didReadData:data];
  }
  else
  {
    NSLog(@"MUSocketConnection delegate did not respond to socket:didReadData:");
  }
}

- (NSString *) host
{
  return _host;
}

- (BOOL) isConnected
{
  if (_socket >= 0)
    return YES;
  else
    return NO;
}

- (BOOL) connect
{
  struct hostent *    server;
  struct sockaddr_in  server_addr;
  
  // First we resolve the domain name
  h_errno = 0;
  if ((server = gethostbyname ([_host cString])) == NULL)
  {
    NSLog([NSString stringWithFormat:@"Error resolving hostname: %s", hstrerror (h_errno)]);
    return NO;
  }
  
  // Next we make our socket, which is always a joy
  errno = 0;
  if ((_socket = socket (AF_INET, SOCK_STREAM, 0)) < 0)
  {
    NSLog ([NSString stringWithFormat:@"Error creating socket: %s", strerror (errno)]);
    return NO;
  }
  
  // If we've gotten this far, we go ahead and make our sockaddr
  server_addr.sin_family = AF_INET;
  server_addr.sin_port = htons (_port);
  memcpy (&server_addr.sin_addr.s_addr, server->h_addr, server->h_length);
  
  // And then we connect!
  errno = 0;
  if ((connect (_socket, (struct sockaddr *)&server_addr,
                sizeof (struct sockaddr)) < 0))
  {
    [self close];
    NSLog ([NSString stringWithFormat:@"Error connecting to host: %s", strerror (errno)]);
    return NO;
  }
  else
    return YES;
}

- (void) readThreadMethod:(id)obj
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  void *buffer = NULL;
  NSData *data = nil;
  ssize_t bytesRead = 0;
  fd_set rdfs;
  int retval;
  
  while ([self isConnected])
  {
    FD_ZERO (&rdfs);
    FD_SET (_socket, &rdfs);
    
    errno = 0;
    retval = select (_socket + 1, &rdfs, NULL, NULL, NULL);
    if (retval < 0)
      perror ("select()");
    else if (retval > 0)
    {
      
      errno = 0;
      buffer = _mu_malloc ([self bufferSize]);
      bytesRead = read (_socket, buffer, [self bufferSize]);
      if (bytesRead < 0)
      {
        NSLog ([NSString stringWithFormat:@"Error reading from socket: %s", strerror(errno)]);
      }
      else if (bytesRead > 0)
      {
        data = [NSData dataWithBytes:buffer length:bytesRead];
        [[self delegate] socket:self didReadData:data];
      }
    }
    //TODO: do we ever not get something since we wait indefinitely?
  }
  
  [pool release];
}

- (BOOL) open;
{          
  if(![self connect])
  {
    return NO;
  }
  
  [NSThread detachNewThreadSelector:@selector (readThreadMethod:)
                           toTarget:self 
                         withObject:nil];
  return YES;
}

- (short) port
{
  return _port;
}

- (void) release
{
  [self close];
}

- (void) setBufferSize:(int)size
{
  _bufferSize = size;
}

- (void) setDelegate:(id)delegate
{
  if (![delegate respondsToSelector:@selector(socket:didReadData:)])
  {
    NSLog(@"MUSocketConnection delegate does not respond to socket:didReadData:");
  }
  
	_delegate = delegate;
}

- (void) setHost:(NSString *)host
{
  NSString *copy = [host copy];
  [_host release];
  _host = copy;
}

- (void) setPort:(short)port
{
  _port = port;
}

- (int) writeData:(NSData *)data
{
  int bytesWritten = 0;
  if([self isConnected])
  {
    errno = 0;
    bytesWritten = write (_socket, [data bytes], [data length]);
    if (bytesWritten < 0)
    {
      NSLog ([NSString stringWithFormat:@"Error writing to socket: %s",strerror (errno)]);
      return -1;
    }
    else if(bytesWritten < [data length])
    {
      NSLog (@"No bytes were written");
    }
  }
  return bytesWritten;
}

@end

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

+ (id) socketWithHost:(NSString *)host port:(short)port
{
    return [[[MUSocketConnection alloc] initWithHost: host port: port] autorelease];
}

- (id) init
{
    _bufferSize = 512;
    _socket = -1;
    return self;
}

- (id) initWithHost:(NSString *)host port:(short)port
{
    [self init];
    [self setHost: host];
    [self setPort: port];
    return self;
}

- (int) bufferSize
{
    return _bufferSize;
}

- (void) close 
{
    if ([self isConnected])
    {
        close(_socket);
        _socket = -1;
    }
}

- (id) delegate 
{
	return _delegate;
}

- (NSString *) host
{
    return _host;
}

- (BOOL) isConnected
{
    return _socket >= 0;
}

- (BOOL) connect
{
    struct hostent *    server;
    struct sockaddr_in  server_addr;
    
    // First we resolve the domain name
    h_errno = 0;
    if ((server = gethostbyname([_host cString])) == NULL)
    {
        //TODO: This should probably be hstrerror
        herror("Error resolving hostname");
        return NO;
    }
    
    // Next we make our socket, which is always a joy
    errno = 0;
    if ((_socket = socket(AF_INET, SOCK_STREAM, 0)) < 0)
    {
        //TODO: This sholud probably be strerror_r
        perror("Error creating socket");
        return NO;
    }
    
    // If we've gotten this far, we go ahead and make our sockaddr
    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(_port);
    memcpy(&server_addr.sin_addr.s_addr, server->h_addr, server->h_length);
    
    // And then we connect!
    errno = 0;
    if ((connect (_socket, (struct sockaddr *)&server_addr,
         sizeof(struct sockaddr)) < 0))
    {
        //TODO: This should probably be strerror_r
        perror("Error connecting to host");
        return NO;
    }

    return YES;
}

- (void) open;
{
    void *buffer = NULL;
    NSData *data = nil;
    ssize_t bytesRead = 0;
            
    [self connect];
    
    //TODO: Thread this
    if ([self isConnected])
    {
        if ((buffer = malloc([self bufferSize])) == NULL)
        {
            NSLog(@"Error Allocating Memory");
        }
        bytesRead = read(_socket, buffer, [self bufferSize]);
        data = [NSData dataWithBytes: buffer length: [self bufferSize]];
        [[self delegate] socket: self didReadData: data];
    }
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

@end

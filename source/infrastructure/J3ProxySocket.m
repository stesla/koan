//
//  J3ProxySocket.m
//  Koan
//
//  Created by Samuel on 2/23/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "J3ProxySocket.h"
#import "J3ProxySettings.h"
#import "J3SocksConstants.h"
#import "J3SocksAuthentication.h"
#import "J3SocksMethodSelection.h"
#import "J3SocksRequest.h"
#import "J3WriteBuffer.h"

@interface J3ProxySocket (Private)

- (void) performUsernamePasswordNegotiation:(id <J3Buffer>)buffer;

@end

@implementation J3ProxySocket

+ (id) socketWithHostname:(NSString *)hostname port:(int)port proxySettings:(J3ProxySettings *)settings;
{
  return [[[self alloc] initWithHostname:hostname port:port proxySettings:settings] autorelease];
}

- (void) dealloc;
{
  [realHostname release];
  [proxySettings release];
  [super dealloc];
}

- (id) initWithHostname:(NSString *)hostnameValue port:(int)portValue proxySettings:(J3ProxySettings *)settings;
{
  if (![super initWithHostname:[settings hostname] port:[[settings port] intValue]])
    return nil;
  [self at:&realHostname put:hostnameValue];
  realPort = portValue;
  [self at:&proxySettings put:settings];
  return self;
}

- (void) performPostConnectNegotiation;
{
  J3SocksMethodSelection * methodSelection = [[[J3SocksMethodSelection alloc] init] autorelease];
  J3SocksRequest * request = [[[J3SocksRequest alloc] initWithHostname:realHostname port:realPort] autorelease];
  J3WriteBuffer * buffer = [J3WriteBuffer buffer];
  
  [buffer setByteDestination:self];
  
  // Select Method
  if ([proxySettings hasAuthentication])
    [methodSelection addMethod:J3SocksUsernamePassword];
  [methodSelection appendToBuffer:buffer];
  [buffer flush];
  [methodSelection parseResponseFromByteSource:self];
  
  // Method Specific Stuff
  if ([methodSelection method] == J3SocksNoAcceptableMethods)
    [J3SocketException socketError:@"No acceptable SOCKS5 methods"];
  else if ([methodSelection method] == J3SocksUsernamePassword)
    [self performUsernamePasswordNegotiation:buffer];
  
  // Make Request
  [request appendToBuffer:buffer];
  [buffer flush];
  [request parseReplyFromByteSource:self];
  if ([request reply] != J3SocksSuccess)
    [J3SocketException socketError:@"Unable to establish connection via proxy"];
}

@end

@implementation J3ProxySocket (Private)

- (void) performUsernamePasswordNegotiation:(id <J3Buffer>)buffer;
{
  J3SocksAuthentication * auth = [[[J3SocksAuthentication alloc] initWithUsername:[proxySettings username] password:[proxySettings password]] autorelease];
  
  [auth appendToBuffer:buffer];
  [buffer flush];
  [auth parseReplyFromSource:self];
  if (![auth authenticated])
    [J3SocketException socketError:@"Could not authenticate to proxy"];
}

@end

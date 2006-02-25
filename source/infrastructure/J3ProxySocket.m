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
#import "J3SocksMethodSelection.h"
#import "J3SocksRequest.h"
#import "J3WriteBuffer.h"

@implementation J3ProxySocket

+ (id) socketWithHostname:(NSString *)hostname port:(int)port proxySettings:(J3ProxySettings *)settings;
{
  return [[[self alloc] initWithHostname:hostname port:port proxySettings:settings] autorelease];
}

- (void) dealloc;
{
  [realHostname release];
  [super dealloc];
}

- (id) initWithHostname:(NSString *)hostnameValue port:(int)portValue proxySettings:(J3ProxySettings *)settings;
{
  if (![super initWithHostname:[settings hostname] port:[[settings port] intValue]])
    return nil;
  [self at:&realHostname put:hostnameValue];
  realPort = portValue;
  return self;
}

- (void) performPostConnectNegotiation;
{
  J3SocksMethodSelection * methodSelection = [[[J3SocksMethodSelection alloc] init] autorelease];
  J3SocksRequest * request = [[[J3SocksRequest alloc] initWithHostname:realHostname port:realPort] autorelease];
  J3WriteBuffer * buffer = [J3WriteBuffer buffer];
  
  [buffer setByteDestination:self];
  [methodSelection appendToBuffer:buffer];
  [buffer flush];
  [methodSelection parseResponseFromByteSource:self];
  if ([methodSelection method] == J3SocksNoAcceptableMethods)
    [J3SocketException socketError:@"No acceptable SOCKS5 methods"];
  [request appendToBuffer:buffer];
  [buffer flush];
  [request parseReplyFromByteSource:self];
  if ([request reply] != J3SocksSuccess)
    [J3SocketException socketError:@"Unable to establish connection via proxy"];
}

@end

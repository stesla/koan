//
// J3ProxySocket.m
//
// Copyright (c) 2006 3James Software
//

#import "J3ProxySocket.h"
#import "J3ProxySettings.h"
#import "J3SocksConstants.h"
#import "J3SocksAuthentication.h"
#import "J3SocksMethodSelection.h"
#import "J3SocksRequest.h"
#import "J3WriteBuffer.h"

@interface J3ProxySocket (Private)

- (void) makeRequest;
- (void) performMethodSpecificNegotiation:(J3SocksMethod)method;
- (void) performUsernamePasswordNegotiation;
- (J3SocksMethod) selectMethod;

@end

#pragma mark -

@implementation J3ProxySocket

+ (id) socketWithHostname:(NSString *)hostname port:(int)port proxySettings:(J3ProxySettings *)settings
{
  return [[[self alloc] initWithHostname:hostname port:port proxySettings:settings] autorelease];
}

- (id) initWithHostname:(NSString *)hostnameValue port:(int)portValue proxySettings:(J3ProxySettings *)settings
{
  if (![super initWithHostname:[settings hostname] port:[[settings port] intValue]])
    return nil;
  
  [self at:&realHostname put:hostnameValue];
  realPort = portValue;
  [self at:&proxySettings put:settings];
  [self at:&outputBuffer put:[J3WriteBuffer buffer]];
  [outputBuffer setByteDestination:self];
  
  return self;
}

- (void) dealloc
{
  [realHostname release];
  [proxySettings release];
  [outputBuffer release];
  [super dealloc];
}

- (void) performPostConnectNegotiation
{
  [self performMethodSpecificNegotiation:[self selectMethod]];
  [self makeRequest];
}

@end

#pragma mark -

@implementation J3ProxySocket (Private)

- (void) makeRequest
{
  J3SocksRequest *request = [[[J3SocksRequest alloc] initWithHostname:realHostname port:realPort] autorelease];

  [request appendToBuffer:outputBuffer];
  [outputBuffer flush];
  [request parseReplyFromByteSource:self];
  if ([request reply] != J3SocksSuccess)
    [J3SocketException socketError:@"Unable to establish connection via proxy"];  
}

- (void) performMethodSpecificNegotiation:(J3SocksMethod)method
{
  if (method == J3SocksNoAcceptableMethods)
    [J3SocketException socketError:@"No acceptable SOCKS5 methods"];
  else if (method == J3SocksUsernamePassword)
    [self performUsernamePasswordNegotiation];  
}

- (void) performUsernamePasswordNegotiation
{
  J3SocksAuthentication *auth = [[[J3SocksAuthentication alloc] initWithUsername:[proxySettings username] password:[proxySettings password]] autorelease];
  
  [auth appendToBuffer:outputBuffer];
  [outputBuffer flush];
  [auth parseReplyFromSource:self];
  if (![auth authenticated])
    [J3SocketException socketError:@"Could not authenticate to proxy"];
}

- (J3SocksMethod) selectMethod
{
  J3SocksMethodSelection *methodSelection = [[[J3SocksMethodSelection alloc] init] autorelease];

  if ([proxySettings hasAuthentication])
    [methodSelection addMethod:J3SocksUsernamePassword];
  [methodSelection appendToBuffer:outputBuffer];
  [outputBuffer flush];
  [methodSelection parseResponseFromByteSource:self];
  return [methodSelection method];  
}

@end

//
//  J3ProxySocket.m
//  Koan
//
//  Created by Samuel on 2/23/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "J3ProxySocket.h"
#import "J3ProxySettings.h"

@implementation J3ProxySocket

+ (id) socketWithHostname:(NSString *)hostname port:(int)port proxySettings:(J3ProxySettings *)settings;
{
  return [[[self alloc] initWithHostname:hostname port:port proxySettings:settings] autorelease];
}

- (id) initWithHostname:(NSString *)hostnameValue port:(int)portValue proxySettings:(J3ProxySettings *)settings;
{
  if (![super initWithHostname:[settings hostname] port:[[settings port] intValue]])
    return nil;
  [self at:&realHostname put:hostnameValue];
  realPort = portValue;
  return self;
}

@end

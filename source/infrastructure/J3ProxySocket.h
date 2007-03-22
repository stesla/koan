//
// J3ProxySocket.h
//
// Copyright (c) 2006 3James Software
//

#import <Cocoa/Cocoa.h>
#import "J3Socket.h"

@class J3ProxySettings;
@class J3WriteBuffer;

@interface J3ProxySocket : J3Socket
{
  J3ProxySettings *proxySettings;
  NSString *realHostname;
  int realPort;
  J3WriteBuffer *outputBuffer;
}

+ (id) socketWithHostname: (NSString *) hostname port: (int) port proxySettings: (J3ProxySettings *) settings;
- (id) initWithHostname: (NSString *) hostname port: (int) port proxySettings: (J3ProxySettings *) settings;

@end

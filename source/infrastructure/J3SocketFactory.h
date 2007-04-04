//
// J3SocketFactory.h
//
// Copyright (c) 2007 3James Software.
//

#import <Cocoa/Cocoa.h>
#import "J3ReadBuffer.h"
#import "J3TelnetConnection.h"

@class J3ProxySettings;

@interface J3SocketFactory : NSObject
{
  BOOL useProxy;
  J3ProxySettings *proxySettings;
}

+ (J3SocketFactory *) defaultFactory;

- (J3Socket *) makeSocketWithHostname: (NSString *) hostname port: (int) port;
- (J3ProxySettings *) proxySettings;
- (void) saveProxySettings;
- (void) toggleUseProxy;
- (BOOL) useProxy;

@end

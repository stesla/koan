//
// J3ConnectionFactory.h
//
// Copyright (c) 2006, 2007 3James Software
//

#import <Cocoa/Cocoa.h>
#import "J3ReadBuffer.h"
#import "J3TelnetConnection.h"

@class J3ProxySettings;

@interface J3ConnectionFactory : NSObject
{
  BOOL useProxy;
  J3ProxySettings *proxySettings;
}

+ (J3ConnectionFactory *) defaultFactory;

- (J3Socket *) makeSocketWithHostname: (NSString *) hostname port: (int) port;
- (J3ProxySettings *) proxySettings;
- (void) saveProxySettings;
- (void) toggleUseProxy;
- (BOOL) useProxy;

@end

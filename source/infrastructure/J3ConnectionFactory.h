//
// J3ConnectionFactory.h
//
// Copyright (c) 2006, 2007 3James Software
//

#import <Cocoa/Cocoa.h>
#import "J3ReadBuffer.h"
#import "J3LineBuffer.h"
#import "J3TelnetConnection.h"

@class J3ProxySettings;

@interface J3ConnectionFactory : NSObject 
{
  BOOL useProxy;
  J3ProxySettings *proxySettings;
}

+ (J3ConnectionFactory *) defaultFactory;

- (J3TelnetConnection *) telnetWithHostname: (NSString *) hostname
                                       port: (int) port
                                   delegate: (NSObject <J3TelnetConnectionDelegate> *) newDelegate;

- (J3ProxySettings *) proxySettings;
- (void) saveProxySettings;
- (void) toggleUseProxy;
- (BOOL) useProxy;

@end

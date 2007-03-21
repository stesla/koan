//
// J3ConnectionFactory.h
//
// Copyright (c) 2006, 2007 3James Software
//

#import <Cocoa/Cocoa.h>
#import "J3Buffer.h"
#import "J3LineBuffer.h"
#import "J3TelnetConnection.h"

@class J3ProxySettings;

@interface J3ConnectionFactory : NSObject 
{
  BOOL useProxy;
  J3ProxySettings *proxySettings;
}

+ (J3ConnectionFactory *) defaultFactory;

- (J3TelnetConnection *) lineAtATimeTelnetWithHostname:(NSString *)hostname
                                        port:(int)port
                                    delegate:(NSObject <J3TelnetConnectionDelegate> *)newDelegate
                          lineBufferDelegate:(NSObject <J3LineBufferDelegate> *)lineBufferDelegate;

- (J3TelnetConnection *) telnetWithHostname:(NSString *)hostname
                             port:(int)port
                      inputBuffer:(NSObject <J3Buffer> *)buffer
                         delegate:(NSObject <J3TelnetConnectionDelegate> *)newDelegate;

- (J3ProxySettings *) proxySettings;
- (void) saveProxySettings;
- (void) toggleUseProxy;
- (BOOL) useProxy;

@end

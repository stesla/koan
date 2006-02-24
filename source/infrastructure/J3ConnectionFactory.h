//
//  J3ConnectionFactory.h
//  Koan
//
//  Created by Samuel on 2/22/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "J3Buffer.h"
#import "J3LineBuffer.h"
#import "J3Telnet.h"

@class J3ProxySettings;

@interface J3ConnectionFactory : NSObject 
{
  BOOL useProxy;
  J3ProxySettings * proxySettings;
}

+ (J3ConnectionFactory *) currentFactory;

- (J3Telnet *) lineAtATimeTelnetWithHostname:(NSString *)hostname
                                        port:(int)port
                                    delegate:(NSObject <J3TelnetConnectionDelegate> *)newDelegate
                          lineBufferDelegate:(NSObject <J3LineBufferDelegate> *)lineBufferDelegate;

- (J3Telnet *) telnetWithHostname:(NSString *)hostname
                             port:(int)port
                      inputBuffer:(NSObject <J3Buffer> *)buffer
                         delegate:(NSObject <J3TelnetConnectionDelegate> *)newDelegate;

- (J3ProxySettings *) proxySettings;
- (void) saveProxySettings;
- (void) toggleUseProxy;
- (BOOL) useProxy;

@end

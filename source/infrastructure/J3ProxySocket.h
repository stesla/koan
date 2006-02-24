//
//  J3ProxySocket.h
//  Koan
//
//  Created by Samuel on 2/23/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "J3Socket.h"

@class J3ProxySettings;

@interface J3ProxySocket : J3Socket
{
  J3ProxySettings * proxySettings;
  NSString * realHostname;
  int realPort;
}

+ (id) socketWithHostname:(NSString *)hostname port:(int)port proxySettings:(J3ProxySettings *)settings;
- (id) initWithHostname:(NSString *)hostname port:(int)port proxySettings:(J3ProxySettings *)settings;

@end

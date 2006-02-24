//
//  J3ProxySettings.h
//  Koan
//
//  Created by Samuel on 2/23/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface J3ProxySettings : NSObject 
{
  NSString * hostname;
  NSNumber * port;
}

+ (id) proxySettings;

- (NSString *) hostname;
- (void) setHostname:(NSString *)value;
- (NSNumber *) port;
- (void) setPort:(NSNumber *)value;

@end

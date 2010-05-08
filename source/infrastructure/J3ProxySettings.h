//
// J3ProxySettings.h
//
// Copyright (c) 2010 3James Software.
//

#import <Cocoa/Cocoa.h>

@interface J3ProxySettings : NSObject <NSCoding>
{
  NSString *hostname;
  NSNumber *port;
  NSString *username;
  NSString *password;
}

+ (id) proxySettings;

- (NSString *) hostname;
- (void) setHostname: (NSString *) value;
- (NSNumber *) port;
- (void) setPort: (NSNumber *) value;
- (NSString *) username;
- (void) setUsername: (NSString *) value;
- (NSString *) password;
- (void) setPassword: (NSString *) value;

- (BOOL) hasAuthentication;

@end

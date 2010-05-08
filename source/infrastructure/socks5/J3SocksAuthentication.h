//
// J3SocksAuthentication.h
//
// Copyright (c) 2010 3James Software.
//

#import <Cocoa/Cocoa.h>

@protocol J3ByteSource;
@protocol J3WriteBuffer;

@interface J3SocksAuthentication : NSObject
{
  NSString *username;
  NSString *password;
  BOOL authenticated;
}

+ (id) socksAuthenticationWithUsername: (NSString *) usernameValue password: (NSString *) passwordValue;

- (id) initWithUsername: (NSString *) usernameValue password: (NSString *) passwordValue;

- (void) appendToBuffer: (NSObject <J3WriteBuffer> *) buffer;
- (BOOL) authenticated;
- (void) parseReplyFromSource: (NSObject <J3ByteSource> *) source;

@end

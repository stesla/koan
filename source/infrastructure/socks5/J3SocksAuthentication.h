//
// J3SocksAuthentication.h
//
// Copyright (c) 2007 3James Software.
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

- (id) initWithUsername: (NSString *) username password: (NSString *) password;
- (void) appendToBuffer: (id <J3WriteBuffer>) buffer;
- (BOOL) authenticated;
- (void) parseReplyFromSource: (id <J3ByteSource>) source;

@end

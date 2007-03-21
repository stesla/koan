//
// J3SocksAuthentication.h
//
// Copyright (c) 2006 3James Software
//

#import <Cocoa/Cocoa.h>

@protocol J3Buffer;
@protocol J3ByteSource;

@interface J3SocksAuthentication : NSObject 
{
  NSString *username;
  NSString *password;
  BOOL authenticated;
}

- (id) initWithUsername: (NSString *)username password: (NSString *)password;
- (void) appendToBuffer: (id <J3Buffer>)buffer;
- (BOOL) authenticated;
- (void) parseReplyFromSource: (id <J3ByteSource>)source;

@end

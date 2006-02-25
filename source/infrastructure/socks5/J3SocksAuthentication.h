//
//  J3SocksAuthentication.h
//  Koan
//
//  Created by Samuel on 2/25/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol J3Buffer;
@protocol J3ByteSource;

@interface J3SocksAuthentication : NSObject 
{
  NSString * username;
  NSString * password;
  BOOL authenticated;
}

- (id) initWithUsername:(NSString *)username password:(NSString *)password;
- (void) appendToBuffer:(id <J3Buffer>)buffer;
- (BOOL) authenticated;
- (void) parseReplyFromSource:(id <J3ByteSource>)source;

@end

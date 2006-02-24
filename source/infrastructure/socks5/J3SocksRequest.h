//
//  J3SocksRequest.h
//  Koan
//
//  Created by Samuel on 2/24/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "J3SocksConstants.h"

@protocol J3Buffer;
@protocol J3ByteSource;

@interface J3SocksRequest : NSObject 
{
  NSString * hostname;
  int port;
  J3SocksReply reply;
}

- (id) initWithHostname:(NSString *)hostnameValue port:(int)portValue;
- (void) appendToBuffer:(id <J3Buffer>)buffer;
- (void) parseReplyFromByteSource:(id <J3ByteSource>)source;
- (J3SocksReply) reply;

@end

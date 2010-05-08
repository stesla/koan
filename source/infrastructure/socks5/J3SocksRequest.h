//
// J3SocksRequest.h
//
// Copyright (c) 2010 3James Software.
//

#import <Cocoa/Cocoa.h>
#import "J3SocksConstants.h"

@protocol J3ByteSource;
@protocol J3WriteBuffer;

@interface J3SocksRequest : NSObject
{
  NSString *hostname;
  int port;
  J3SocksReply reply;
}

+ (id) socksRequestWithHostname: (NSString *) hostnameValue port: (int) portValue;

- (id) initWithHostname: (NSString *) hostnameValue port: (int) portValue;

- (void) appendToBuffer: (NSObject <J3WriteBuffer> *) buffer;
- (void) parseReplyFromByteSource: (NSObject <J3ByteSource> *) source;
- (J3SocksReply) reply;

@end

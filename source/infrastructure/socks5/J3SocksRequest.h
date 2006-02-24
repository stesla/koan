//
//  J3SocksRequest.h
//  Koan
//
//  Created by Samuel on 2/24/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol J3Buffer;

@interface J3SocksRequest : NSObject 
{
  NSString * hostname;
  int port;
}

- (id) initWithHostname:(NSString *)hostnameValue port:(int)portValue;
- (void) appendToBuffer:(id <J3Buffer>)buffer;

@end

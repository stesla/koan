//
//  J3SocksRequest.m
//  Koan
//
//  Created by Samuel on 2/24/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "J3SocksRequest.h"
#import "J3Buffer.h"


@implementation J3SocksRequest

- (void) appendToBuffer:(id <J3Buffer>)buffer;
{
  [buffer append:5]; //version: 5
  [buffer append:1]; //command: CONNECT
  [buffer append:0]; //reserved
  [buffer append:3]; //address type: DOMAINNAME
  [buffer append:[hostname length]]; //length of domain
  [buffer appendString:hostname]; //domain
  [buffer append:(0xFF00 & htons(port)) >> 8]; //most significant byte of port
  [buffer append:0x00FF & htons(port)]; //least significant byte of port
}

- (id) initWithHostname:(NSString *)hostnameValue port:(int)portValue;
{
  if (![super init])
    return nil;
  [self at:&hostname put:hostnameValue];
  port = portValue;
  return self;
}

@end

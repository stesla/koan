//
//  J3SocksMethodSelection.m
//  Koan
//
//  Created by Samuel Tesla on 11/22/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "J3SocksMethodSelection.h"


@implementation J3SocksMethodSelection
- (void) addMethod:(J3SocksMethod)method;
{
  char bytes[1] = {method};
  [methods appendBytes:bytes length:1];
}

- (void) appendToBuffer:(id <J3Buffer>)buffer;
{
  const uint8_t * bytes;
  int i;
  
  [buffer append:J3SocksVersion];
  [buffer append:[methods length]];
  bytes = [methods bytes];
  for (i = 0; i < [methods length]; i++)
    [buffer append:bytes[i]];
}

- (void) dealloc;
{
  [methods release];
  [super dealloc];
}

- (id) init;
{
  if (![super init])
    return nil;
  methods = [[NSMutableData alloc] init];
  [self addMethod:J3SocksNoAuthentication];
  return self;
}
@end

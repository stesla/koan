//
//  J3ProxySettings.m
//  Koan
//
//  Created by Samuel on 2/23/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "J3ProxySettings.h"
#import "MUCodingService.h"

@implementation J3ProxySettings

+ (id) proxySettings;
{
  return [[[self alloc] init] autorelease];
}

- (id) init;
{
  if (![super init])
    return nil;
  [self setHostname:@""];
  [self setPort:[NSNumber numberWithInt:1080]];
  return self;
}

- (NSString *) description;
{
  return [NSString stringWithFormat:@"%@:%@", hostname, port];
}

- (id) initWithCoder:(NSCoder *)coder;
{
  [MUCodingService decodeProxySettings:self withCoder:coder];
  return self;
}

- (void) encodeWithCoder:(NSCoder *)coder;
{
  [MUCodingService encodeProxySettings:self withCoder:coder];
}

- (NSString *) hostname;
{
  return hostname;
}

- (void) setHostname:(NSString *)value;
{
  [self at:&hostname put:value];
}

- (NSNumber *) port;
{
  return port;
}

- (void) setPort:(NSNumber *)value;
{
  [self at:&port put:value];
}

@end

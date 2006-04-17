//
// J3ProxySettings.m
//
// Copyright (c) 2006 3James Software
//

#import "J3ProxySettings.h"
#import "MUCodingService.h"

@implementation J3ProxySettings

+ (id) proxySettings
{
  return [[[self alloc] init] autorelease];
}

- (id) init
{
  if (![super init])
    return nil;
  
  [self setHostname:@""];
  [self setPort:[NSNumber numberWithInt:1080]];
  
  return self;
}

- (void) dealloc
{
  [hostname release];
  [port release];
  [super dealloc];
}

- (NSString *) description
{
  return [NSString stringWithFormat:@"%@:%@", hostname, port];
}

- (NSString *) hostname
{
  return hostname;
}

- (void) setHostname:(NSString *)value
{
  [self at:&hostname put:value];
}

- (NSNumber *) port
{
  return port;
}

- (void) setPort:(NSNumber *)value
{
  [self at:&port put:value];
}

- (NSString *) username
{
  return username;
}

- (void) setUsername:(NSString *)value
{
  [self at:&username put:value];
}

- (NSString *) password
{
  return password;
}

- (void) setPassword:(NSString *)value
{
  [self at:&password put:value];
}

- (BOOL) hasAuthentication
{
  return username && ([username length] > 0);
}

#pragma mark -
#pragma mark NSCoding protocol

- (id) initWithCoder:(NSCoder *)coder
{
  [MUCodingService decodeProxySettings:self withCoder:coder];
  return self;
}

- (void) encodeWithCoder:(NSCoder *)coder
{
  [MUCodingService encodeProxySettings:self withCoder:coder];
}

@end

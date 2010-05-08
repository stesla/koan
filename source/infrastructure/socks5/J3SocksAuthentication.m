//
// J3SocksAuthentication.m
//
// Copyright (c) 2010 3James Software.
//

#import "J3SocksAuthentication.h"
#import "J3WriteBuffer.h"
#import "J3ByteSource.h"
#import "J3SocksConstants.h"

@implementation J3SocksAuthentication

+ (id) socksAuthenticationWithUsername: (NSString *) usernameValue password: (NSString *) passwordValue
{
  return [[[J3SocksAuthentication alloc] initWithUsername: usernameValue password: passwordValue] autorelease];
}

- (id) initWithUsername: (NSString *) usernameValue password: (NSString *) passwordValue
{
  if (!(self = [super init]))
    return nil;
  
  username = [usernameValue copy];
  password = [passwordValue copy];
  return self;
}

- (void) dealloc
{
  [username release];
  [password release];
  [super dealloc];
}

- (void) appendToBuffer: (NSObject <J3WriteBuffer> *) buffer
{
  [buffer appendByte: J3SocksUsernamePasswordVersion];
  [buffer appendByte: [username length]];
  [buffer appendString: username];
  [buffer appendByte: [password length]];
  [buffer appendString: password];
}

- (BOOL) authenticated
{
  return authenticated;
}

- (void) parseReplyFromSource: (NSObject <J3ByteSource> *) source
{
  NSData *reply = [source readExactlyLength: 2];
  if ([reply length] != 2)
    return;
  authenticated = ((uint8_t *) [reply bytes])[1] == 0 ? YES : NO;
}

@end

//
// J3SocksAuthentication.m
//
// Copyright (c) 2007 3James Software.
//

#import "J3SocksAuthentication.h"
#import "J3WriteBuffer.h"
#import "J3ByteSource.h"
#import "J3SocksConstants.h"

@implementation J3SocksAuthentication

- (id) initWithUsername: (NSString *) usernameValue password: (NSString *) passwordValue
{
  if (![super init])
    return nil;
  [self at: &username put: usernameValue];
  [self at: &password put: passwordValue];
  return self;
}

- (void) dealloc
{
  [username release];
  [password release];
  [super dealloc];
}

- (void) appendToBuffer: (id <J3WriteBuffer>) buffer
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

- (void) parseReplyFromSource: (id <J3ByteSource>) source
{
  uint8_t reply[2] = {0, 0};
  
  [J3ByteSource ensureBytesReadFromSource: source intoBuffer: reply ofLength: 2];
  authenticated = reply[1] == 0 ? YES : NO;
}

@end

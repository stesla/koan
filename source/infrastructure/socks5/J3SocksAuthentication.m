//
//  J3SocksAuthentication.m
//  Koan
//
//  Created by Samuel on 2/25/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "J3SocksAuthentication.h"
#import "J3Buffer.h"
#import "J3ByteSource.h"


@implementation J3SocksAuthentication

- (void) dealloc;
{
  [username release];
  [password release];
  [super dealloc];
}

- (id) initWithUsername:(NSString *)usernameValue password:(NSString *)passwordValue;
{
  if (![super init])
    return nil;
  [self at:&username put:usernameValue];
  [self at:&password put:passwordValue];
  return self;
}

- (void) appendToBuffer:(id <J3Buffer>)buffer;
{
  [buffer append:5];
  [buffer append:[username length]];
  [buffer appendString:username];
  [buffer append:[password length]];
  [buffer appendString:password];
}

- (BOOL) authenticated;
{
  return authenticated;
}

- (void) parseReplyFromSource:(id <J3ByteSource>)source;
{
  uint8_t reply[2];
  
  [J3ByteSource ensureBytesReadFromSource:source intoBuffer:reply ofLength:2];
  authenticated = !reply[1];
}

@end

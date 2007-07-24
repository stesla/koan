//
// J3SocksMethodSelection.m
//
// Copyright (c) 2007 3James Software.
//

#import "J3SocksMethodSelection.h"
#import "J3WriteBuffer.h"
#import "J3ByteSource.h"

@implementation J3SocksMethodSelection

- (void) addMethod: (J3SocksMethod)method
{
  char bytes[1] = {method};
  [methods appendBytes: bytes length: 1];
}

- (void) appendToBuffer: (id <J3WriteBuffer>) buffer
{
  const uint8_t *bytes;
  
  [buffer appendByte: J3SocksVersion];
  [buffer appendByte: [methods length]];
  bytes = [methods bytes];
  
  for (unsigned i = 0; i < [methods length]; i++)
    [buffer appendByte: bytes[i]];
}

- (void) dealloc
{
  [methods release];
  [super dealloc];
}

- (id) init
{
  if (![super init])
    return nil;
  
  methods = [[NSMutableData alloc] init];
  [self addMethod: J3SocksNoAuthentication];
  
  return self;
}

- (J3SocksMethod) method
{
  return selectedMethod;
}

- (void) parseResponseFromByteSource: (id <J3ByteSource>) byteSource
{
  NSData *reply = [byteSource readExactlyLength: 2];
  if ([reply length] != 2)
    return;
  selectedMethod = ((uint8_t *) [reply bytes])[1];    
}

@end

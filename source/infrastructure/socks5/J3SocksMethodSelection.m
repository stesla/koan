//
// J3SocksMethodSelection.m
//
// Copyright (c) 2005, 2006 3James Software
//

#import "J3SocksMethodSelection.h"
#import "J3Buffer.h"
#import "J3ByteSource.h"

@implementation J3SocksMethodSelection

- (void) addMethod: (J3SocksMethod)method;
{
  char bytes[1] = {method};
  [methods appendBytes: bytes length: 1];
}

- (void) appendToBuffer: (id <J3Buffer>)buffer;
{
  const uint8_t *bytes;
  int i;
  
  [buffer appendByte: J3SocksVersion];
  [buffer appendByte: [methods length]];
  bytes = [methods bytes];
  for (i = 0; i < [methods length]; i++)
    [buffer appendByte: bytes[i]];
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
  [self addMethod: J3SocksNoAuthentication];
  
  return self;
}

- (J3SocksMethod) method;
{
  return selectedMethod;
}

- (void) parseResponseFromByteSource: (id <J3ByteSource>)byteSource;
{
  uint8_t response[2] = {0, 0};
  
  [J3ByteSource ensureBytesReadFromSource: byteSource intoBuffer: response ofLength: 2];
  selectedMethod = response[1];    
}

@end
//
// J3SocksRequest.m
//
// Copyright (c) 2006 3James Software
//

#import "J3SocksRequest.h"
#import "J3Buffer.h"
#import "J3ByteSource.h"

@implementation J3SocksRequest

- (id) initWithHostname: (NSString *)hostnameValue port: (int)portValue;
{
  if (![super init])
    return nil;
  [self at: &hostname put: hostnameValue];
  port = portValue;
  reply = J3SocksNoReply;
  return self;
}

- (void) dealloc
{
  [hostname release];
  [super dealloc];
}

- (void) appendToBuffer: (id <J3Buffer>)buffer
{
  [buffer append: J3SocksVersion];
  [buffer append: J3SocksConnect];
  [buffer append: 0]; //reserved
  [buffer append: J3SocksDomainName];
  [buffer append: [hostname length]];
  [buffer appendString: hostname];
  [buffer append: (0xFF00 & port) >> 8]; //most significant byte of port
  [buffer append: (0x00FF & port)]; //least significant byte of port
}

- (void) parseReplyFromByteSource: (id <J3ByteSource>)source
{
  uint8_t buffer[261];
  unsigned bytesRead = 0;

  memset(buffer, 0, sizeof(uint8_t) * 261);

  [J3ByteSource ensureBytesReadFromSource: source intoBuffer: buffer ofLength: 4];
  bytesRead = 4;
  switch (buffer[3])
  {
    case J3SocksIPV4:
      [J3ByteSource ensureBytesReadFromSource: source intoBuffer: buffer+bytesRead ofLength: 4];
      bytesRead += 4;
      break;
      
    case J3SocksDomainName:
      [J3ByteSource ensureBytesReadFromSource: source intoBuffer: buffer+bytesRead ofLength: 1];
      bytesRead += 1;
      [J3ByteSource ensureBytesReadFromSource: source intoBuffer: buffer+bytesRead ofLength: buffer[4]];
      bytesRead += buffer[4];
      break;
      
    case J3SocksIPV6:
      [J3ByteSource ensureBytesReadFromSource: source intoBuffer: buffer+bytesRead ofLength: 16];
      bytesRead += 16;
      break;
  }
  [J3ByteSource ensureBytesReadFromSource: source intoBuffer: buffer+bytesRead ofLength: 2];
  
  reply = buffer[1];
}

- (J3SocksReply) reply
{
  return reply;
}

@end

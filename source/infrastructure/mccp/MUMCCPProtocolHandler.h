//
// MUMCCPProtocolHandler.h
//
// Copyright (c) 2010 3James Software.
//

#import <Cocoa/Cocoa.h>

#import "J3Protocol.h"
#import "J3TelnetConnectionState.h"

#include <zlib.h>

@interface MUMCCPProtocolHandler : J3ByteProtocolHandler
{
  J3TelnetConnectionState *connectionState;
  z_stream *stream;
  
  uint8_t *inbuf;
  unsigned inalloc;
  unsigned insize;
  
  uint8_t *outbuf;
  unsigned outalloc;
  unsigned outsize;
}

+ (id) protocolHandlerWithConnectionState: (J3TelnetConnectionState *) telnetConnectionState;
- (id) initWithConnectionState: (J3TelnetConnectionState *) telnetConnectionState;

@end

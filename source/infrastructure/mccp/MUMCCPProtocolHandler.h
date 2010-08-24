//
// MUMCCPProtocolHandler.h
//
// Copyright (c) 2010 3James Software.
//

#import <Cocoa/Cocoa.h>

#import "J3Protocol.h"
#import "J3TelnetConnectionState.h"

typedef struct z_stream_s z_stream;

@protocol MUMCCPProtocolHandlerDelegate;

@interface MUMCCPProtocolHandler : J3ByteProtocolHandler
{
  J3TelnetConnectionState *connectionState;
  NSObject <MUMCCPProtocolHandlerDelegate> *delegate;
  
  z_stream *stream;
  
  uint8_t *inbuf;
  unsigned inalloc;
  unsigned insize;
  
  uint8_t *outbuf;
  unsigned outalloc;
  unsigned outsize;
}

+ (id) protocolHandlerWithStack: (J3ProtocolStack *) stack connectionState: (J3TelnetConnectionState *) telnetConnectionState;
- (id) initWithStack: (J3ProtocolStack *) stack connectionState: (J3TelnetConnectionState *) telnetConnectionState;

- (NSObject <MUMCCPProtocolHandlerDelegate> *) delegate;
- (void) setDelegate: (NSObject <MUMCCPProtocolHandlerDelegate> *) object;

@end

#pragma mark -

@protocol MUMCCPProtocolHandlerDelegate

- (void) log: (NSString *) message arguments: (va_list) args;

@end

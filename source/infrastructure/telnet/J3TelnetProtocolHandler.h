//
// J3TelnetProtocolHandler.h
//
// Copyright (c) 2010 3James Software.
//s

#import <Cocoa/Cocoa.h>
#import "J3Protocol.h"
#import "J3TelnetConnectionState.h"
#import "J3TelnetConstants.h"
#import "J3TelnetOption.h"
#import "J3TelnetStateMachine.h"

@class J3TelnetState;
@protocol J3TelnetProtocolHandlerDelegate;
@protocol J3WriteBuffer;

#pragma mark -

@protocol J3TelnetProtocolHandler

- (void) bufferSubnegotiationByte: (uint8_t) byte;
- (void) bufferTextByte: (uint8_t) byte;

- (void) handleBufferedSubnegotiation;
- (void) log: (NSString *) message, ...;
- (NSString *) optionNameForByte: (uint8_t) byte;

- (void) receivedDo: (uint8_t) option;
- (void) receivedDont: (uint8_t) option;
- (void) receivedWill: (uint8_t) option;
- (void) receivedWont: (uint8_t) option;

@end

#pragma mark -

@interface J3TelnetProtocolHandler : J3ProtocolHandler <J3TelnetProtocolHandler, J3TelnetOptionDelegate>
{
  J3TelnetConnectionState *connectionState;
  J3TelnetStateMachine *stateMachine;
  
  NSMutableData *textBuffer;
  NSMutableData *subnegotiationBuffer;
  
  NSObject <J3TelnetProtocolHandlerDelegate> *delegate;
  J3TelnetOption *options[TELNET_OPTION_MAX];
  BOOL receivedCR;
}

@property (readonly) J3TelnetConnectionState *connectionState;

+ (id) protocolHandlerWithConnectionState: (J3TelnetConnectionState *) telnetConnectionState;
- (id) initWithConnectionState: (J3TelnetConnectionState *) telnetConnectionState;

- (NSObject <J3TelnetProtocolHandlerDelegate> *) delegate;
- (void) setDelegate: (NSObject <J3TelnetProtocolHandlerDelegate> *) object;

// Option negotation.

- (void) disableOptionForHim: (uint8_t) option;
- (void) disableOptionForUs: (uint8_t) option;
- (void) enableOptionForHim: (uint8_t) option;
- (void) enableOptionForUs: (uint8_t) option;
- (BOOL) optionYesForHim: (uint8_t) option;
- (BOOL) optionYesForUs: (uint8_t) option;- (void) shouldAllowDo: (BOOL) value forOption: (uint8_t) option;
- (void) shouldAllowWill: (BOOL) value forOption: (uint8_t) option;

@end

#pragma mark -

@protocol J3TelnetProtocolHandlerDelegate

- (void) log: (NSString *) message arguments: (va_list) args;
- (void) writeDataToSocket: (NSData *) data;

@end

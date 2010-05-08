//
// J3TelnetEngine.h
//
// Copyright (c) 2010 3James Software.
//

#import <Cocoa/Cocoa.h>
#import "J3TelnetConstants.h"
#import "J3TelnetOption.h"

@class J3TelnetState;
@protocol J3TelnetEngineDelegate;
@protocol J3WriteBuffer;

enum charsetNegotiationStatus
{
  J3TelnetCharsetNegotiationInactive = 0,
  J3TelnetCharsetNegotiationActive = 1,
  J3TelnetCharsetNegotiationIgnoreRejected = 2
};

@interface J3TelnetEngine : NSObject <J3TelnetOptionDelegate>
{
  NSObject <J3TelnetEngineDelegate> *delegate;
  J3TelnetState *state;
  J3TelnetOption *options[TELNET_OPTION_MAX];
  BOOL receivedCR;
  BOOL telnetConfirmed;
  unsigned nextTerminalTypeIndex;
  enum charsetNegotiationStatus charsetNegotiationStatus;
  NSStringEncoding stringEncoding;
}

+ (id) engine;

- (NSObject <J3TelnetEngineDelegate> *) delegate;
- (void) setDelegate: (NSObject <J3TelnetEngineDelegate> *) object;
- (void) log: (NSString *) message, ...;

// Parsing.

- (void) bufferTextInputByte: (uint8_t) byte;
- (void) parseData: (NSData *) data;
- (void) consumeReadBufferAsSubnegotiation;
- (void) consumeReadBufferAsText;
- (NSData *) preprocessOutput: (NSData *) data;

// Output.

- (void) endOfRecord;
- (void) goAhead;

// Option negotation.

- (void) disableOptionForHim: (uint8_t) option;
- (void) disableOptionForUs: (uint8_t) option;
- (void) enableOptionForHim: (uint8_t) option;
- (void) enableOptionForUs: (uint8_t) option;
- (BOOL) optionYesForHim: (uint8_t) option;
- (BOOL) optionYesForUs: (uint8_t) option;
- (void) receivedDo: (uint8_t) option;
- (void) receivedDont: (uint8_t) option;
- (void) receivedWill: (uint8_t) option;
- (void) receivedWont: (uint8_t) option;
- (void) shouldAllowDo: (BOOL) value forOption: (uint8_t) option;
- (void) shouldAllowWill: (BOOL) value forOption: (uint8_t) option;

// Option subnegotiation.

- (void) handleIncomingSubnegotiation: (NSData *) subnegotiationData;

// Telnet option names.

- (NSString *) optionNameForByte: (uint8_t) byte;

// Telnet confirmation.

- (void) confirmTelnet;
- (BOOL) telnetConfirmed;

// String encoding.

- (NSStringEncoding) stringEncoding;

@end

#pragma mark -

@protocol J3TelnetEngineDelegate

- (void) bufferInputByte: (uint8_t) byte;
- (void) log: (NSString *) message arguments: (va_list) args;
- (void) consumeReadBufferAsSubnegotiation;
- (void) consumeReadBufferAsText;
- (void) writeData: (NSData *) data;

@end

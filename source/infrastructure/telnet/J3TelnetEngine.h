//
// J3TelnetEngine.h
//
// Copyright (c) 2007 3James Software.
//

#import <Cocoa/Cocoa.h>
#import "J3TelnetConstants.h"
#import "J3TelnetOption.h"

@class J3TelnetState;
@protocol J3ReadBuffer;
@protocol J3TelnetEngineDelegate;
@protocol J3WriteBuffer;

@interface J3TelnetEngine : NSObject <J3TelnetOptionDelegate>
{
  NSObject <J3TelnetEngineDelegate> *delegate;
  J3TelnetState *state;
  J3TelnetOption *options[TELNET_OPTION_MAX];
}

+ (id) engine;

- (void) bufferInputByte: (uint8_t) byte;
- (void) disableOptionForHim: (uint8_t) option;
- (void) disableOptionForUs: (uint8_t) option;
- (void) enableOptionForHim: (uint8_t) option;
- (void) enableOptionForUs: (uint8_t) option;
- (void) endOfRecord;
- (void) goAhead;
- (void) log: (NSString *) message, ...;
- (void) negotiateOptions;
- (BOOL) optionYesForHim: (uint8_t) option;
- (BOOL) optionYesForUs: (uint8_t) option;
- (NSString *) optionNameForByte: (uint8_t) byte;
- (void) parseData: (NSData *) data;
- (NSData *) preprocessOutput: (NSData *) data;
- (void) shouldAllowDo: (BOOL) value forOption: (uint8_t) option;
- (void) shouldAllowWill: (BOOL) value forOption: (uint8_t) option;
- (void) setDelegate: (NSObject <J3TelnetEngineDelegate> *) object;
- (void) receivedDo: (uint8_t) option;
- (void) receivedDont: (uint8_t) option;
- (void) receivedWill: (uint8_t) option;
- (void) receivedWont: (uint8_t) option;

@end

#pragma mark -

@protocol J3TelnetEngineDelegate

- (void) bufferInputByte: (uint8_t) byte;
- (void) log: (NSString *) message arguments: (va_list) args;
- (void) writeData: (NSData *) data;

@end

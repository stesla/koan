//
// J3TelnetEngine.h
//
// Copyright (c) 2007 3James Software.
//

#import <Cocoa/Cocoa.h>
#import "J3TelnetOption.h"

@class J3TelnetState;
@protocol J3ReadBuffer;
@protocol J3TelnetEngineDelegate;
@protocol J3WriteBuffer;

@interface J3TelnetEngine : NSObject <J3TelnetOptionDelegate>
{
  NSObject <J3TelnetEngineDelegate> *delegate;
  J3TelnetState *state;
}

+ (id) engine;

- (void) bufferInputByte: (uint8_t) byte;
- (void) goAhead;
- (void) log: (NSString *) message, ...;
- (NSString *) optionNameForByte: (uint8_t) byte;
- (void) parseData: (NSData *) data;
- (NSData *) preprocessOutput: (NSData *) data;
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

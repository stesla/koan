//
// J3TelnetEngine.h
//
// Copyright (c) 2005 3James Software
//

#import <Cocoa/Cocoa.h>

@protocol J3ReadBuffer;
@protocol J3WriteBuffer;
@class J3TelnetState;

@protocol J3TelnetEngineDelegate

- (void) bufferOutputByte: (uint8_t) byte;
- (void) flushOutput;

@end

@interface J3TelnetEngine : NSObject
{
  NSObject <J3TelnetEngineDelegate> *delegate;
  NSObject <J3ReadBuffer> *inputBuffer;
  J3TelnetState *state;
}

+ (id) engine;

- (NSString *) optionNameForByte: (uint8_t) byte;

- (void) bufferInputByte: (uint8_t) byte;
- (void) bufferOutputByte: (uint8_t) byte;
- (void) dont: (uint8_t) byte;
- (void) handleEndOfReceivedData;
- (BOOL) hasInputBuffer: (NSObject <J3ReadBuffer> *)buffer;
- (void) goAhead;
- (void) parseData: (NSData *) data;
- (void) setDelegate: (NSObject <J3TelnetEngineDelegate> *) object;
- (void) setInputBuffer: (NSObject <J3ReadBuffer> *) buffer;
- (void) wont: (uint8_t) byte;

@end

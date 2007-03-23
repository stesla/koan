//
// J3TelnetEngine.h
//
// Copyright (c) 2005 3James Software
//

#import <Cocoa/Cocoa.h>

@protocol J3ReadBuffer;
@protocol J3WriteBuffer; 
@class J3TelnetState;

@interface J3TelnetEngine : NSObject
{
  NSObject <J3ReadBuffer> *inputBuffer;
  NSObject <J3WriteBuffer> *outputBuffer;
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
- (void) parse: (uint8_t) byte;
- (void) parse: (uint8_t *) bytes length: (int) count;
- (void) setInputBuffer: (NSObject <J3ReadBuffer> *) buffer;
- (void) setOutputBuffer: (NSObject <J3WriteBuffer> *) buffer;
- (void) wont: (uint8_t) byte;

@end

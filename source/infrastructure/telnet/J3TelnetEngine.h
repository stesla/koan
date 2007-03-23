//
// J3TelnetEngine.h
//
// Copyright (c) 2005 3James Software
//

#import <Cocoa/Cocoa.h>

@protocol J3Buffer;
@class J3TelnetState;
@class J3WriteBuffer; 

@interface J3TelnetEngine : NSObject
{
  NSObject <J3Buffer> *inputBuffer;
  J3WriteBuffer *outputBuffer;
  J3TelnetState *state;
}

+ (id) engine;

- (NSString *) optionNameForByte: (uint8_t) byte;

- (void) bufferInputByte: (uint8_t) byte;
- (void) bufferOutputByte: (uint8_t) byte;
- (void) dont: (uint8_t) byte;
- (BOOL) hasInputBuffer: (id <J3Buffer>)buffer;
- (void) goAhead;
- (void) parse: (uint8_t) byte;
- (void) parse: (uint8_t *) bytes length: (int) count;
- (void) setInputBuffer: (NSObject <J3Buffer> *) buffer;
- (void) setOutputBuffer: (J3WriteBuffer *) buffer;
- (void) wont: (uint8_t) byte;

@end

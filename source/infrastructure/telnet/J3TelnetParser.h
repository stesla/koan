//
// J3TelnetParser.h
//
// Copyright (c) 2005 3James Software
//

#import <Cocoa/Cocoa.h>
#import "J3Buffer.h"

@class J3TelnetState;

@interface J3TelnetParser : NSObject 
{
  NSObject <J3Buffer> *inputBuffer;
  NSObject <J3Buffer> *outputBuffer;
  J3TelnetState *state;
}

+ (id) parser;

- (NSString *) optionNameForByte:(uint8_t)byte;

- (void) bufferInputByte:(uint8_t)byte;
- (void) bufferOutputByte:(uint8_t)byte;
- (void) dont:(uint8_t)byte;
- (BOOL) hasInputBuffer:(id <J3Buffer>)buffer;
- (void) parse:(uint8_t)byte;
- (void) parse:(uint8_t *)bytes length:(int)count;
- (void) setInputBuffer:(NSObject <J3Buffer> *)buffer;
- (void) setOutputBuffer:(NSObject <J3Buffer> *)buffer;
- (void) wont:(uint8_t)byte;

@end

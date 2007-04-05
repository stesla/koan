//
// J3TelnetEngine.h
//
// Copyright (c) 2007 3James Software.
//

#import <Cocoa/Cocoa.h>

@class J3TelnetState;
@protocol J3ReadBuffer;
@protocol J3TelnetEngineDelegate;
@protocol J3WriteBuffer;

@interface J3TelnetEngine : NSObject
{
  NSObject <J3TelnetEngineDelegate> *delegate;
  J3TelnetState *state;
}

+ (id) engine;


- (void) bufferInputByte: (uint8_t) byte;
- (void) dont: (uint8_t) byte;
- (void) goAhead;
- (NSString *) optionNameForByte: (uint8_t) byte;
- (void) parseData: (NSData *) data;
- (NSData *) preprocessOutput: (NSData *) data;
- (void) setDelegate: (NSObject <J3TelnetEngineDelegate> *) object;
- (void) wont: (uint8_t) byte;

@end

#pragma mark -

@protocol J3TelnetEngineDelegate

- (void) bufferInputByte: (uint8_t) byte;
- (void) writeDataWithPriority: (NSData *) data;

@end

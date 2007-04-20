//
// J3TelnetState.h
//
// Copyright (c) 2007 3James Software.
//

#import <Cocoa/Cocoa.h>

@class J3ByteSet;
@class J3TelnetEngine;

@interface J3TelnetState : NSObject

+ (id) state;

+ (J3ByteSet *) telnetCommandBytes;

- (J3TelnetState *) parse: (uint8_t) byte forEngine: (J3TelnetEngine *) engine;

@end

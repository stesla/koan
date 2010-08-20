//
// J3TelnetState.h
//
// Copyright (c) 2010 3James Software.
//

#import <Cocoa/Cocoa.h>

#import "J3TelnetProtocolHandler.h"
#import "J3TelnetStateMachine.h"

@class J3ByteSet;

@interface J3TelnetState : NSObject

+ (id) state;

+ (J3ByteSet *) telnetCommandBytes;

- (J3TelnetState *) parse: (uint8_t) byte
          forStateMachine: (J3TelnetStateMachine *) stateMachine
                 protocol: (NSObject <J3TelnetProtocolHandler> *) protocol;

@end

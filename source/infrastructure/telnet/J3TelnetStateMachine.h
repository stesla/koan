//
// J3TelnetStateMachine.h
//
// Copyright (c) 2010 3James Software.
//

#import <Cocoa/Cocoa.h>

@class J3TelnetState;
@protocol J3TelnetProtocolHandler;

@interface J3TelnetStateMachine : NSObject
{
  J3TelnetState *state;
  BOOL telnetConfirmed;
}

@property (retain, nonatomic) J3TelnetState *state;
@property (assign, nonatomic) BOOL telnetConfirmed;

+ (id) stateMachine;

- (void) confirmTelnet;
- (void) parse: (uint8_t) byte forProtocol: (NSObject <J3TelnetProtocolHandler> *) protocol;

@end

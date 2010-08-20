//
// J3TelnetStateMachine.m
//
// Copyright (c) 2010 3James Software.
//

#import "J3TelnetStateMachine.h"

#import "J3TelnetTextState.h"

@implementation J3TelnetStateMachine

@synthesize state, telnetConfirmed;

+ (id) stateMachine
{
  return [[[self alloc] init] autorelease];
}

- (id) init
{
  if (!(self = [super init]))
    return nil;
  
  self.state = [J3TelnetTextState state];
  self.telnetConfirmed = NO;
  
  return self;
}

- (void) confirmTelnet
{
  self.telnetConfirmed = YES;
}

- (void) parse: (uint8_t) byte forProtocol: (NSObject <J3TelnetProtocolHandler> *) protocol;
{
  self.state = [state parse: byte forStateMachine: self protocol: protocol];
}

@end

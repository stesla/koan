//
//  J3TelnetOption.m
//  Koan
//
//  Created by Samuel Tesla on 4/10/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "J3TelnetOption.h"

@interface J3TelnetOption (Private)

- (void) demandDisableState: (J3TelnetQState *) state
              ifAcknowledge: (SEL) acknowledge
                    ifAllow: (SEL) allow;
- (void) sendDo;
- (void) sendDont;
- (void) sendWill;
- (void) sendWont;

@end

@implementation J3TelnetOption

- (id) initWithOption: (int) newOption delegate: (id <J3TelnetOptionDelegate>) object
{
  if (![super init])
    return nil;
  option = newOption;
  delegate = object;
  return self;
}

- (void) weDo
{
}

- (void) weDont
{
}

- (void) weWill
{
}

- (void) weWont
{
}

- (void) heDo
{
}

- (void) heDont
{
  [self demandDisableState: &us 
             ifAcknowledge: @selector (sendWont) 
                   ifAllow: @selector (sendWill)];
}

- (void) heWill
{
}

- (void) heWont
{
  [self demandDisableState: &him 
             ifAcknowledge: @selector (sendDont) 
                   ifAllow: @selector (sendDo)];
}

- (J3TelnetQState) him
{
  return him;
}

- (void) setHim: (J3TelnetQState) state
{
  him = state;
}

- (J3TelnetQState) us
{
  return us;
}

- (void) setUs: (J3TelnetQState) state
{
  us = state;
}

@end

#pragma mark -

@implementation J3TelnetOption (Private)

- (void) demandDisableState: (J3TelnetQState *) state
              ifAcknowledge: (SEL) acknowledge
                    ifAllow: (SEL) allow
{
  switch (*state)
  {
    case J3TelnetQNo:
      break;
      
    case J3TelnetQYes:
      *state = J3TelnetQNo;
      [self performSelector: acknowledge];
      break;
      
    case J3TelnetQWantNoOpposite:
      *state = J3TelnetQWantYesEmpty;
      [self performSelector: allow];
      break;
      
    case J3TelnetQWantNoEmpty:
    case J3TelnetQWantYesEmpty:
    case J3TelnetQWantYesOpposite:
      *state = J3TelnetQNo;
      break;
  }  
}

- (void) sendDo
{
  [delegate do: option];
}

- (void) sendDont
{
  [delegate dont: option];
}

- (void) sendWill
{
  [delegate will: option];
}

- (void) sendWont
{
  [delegate wont: option];
}

@end



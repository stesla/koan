//
//  J3TelnetOption.m
//  Koan
//
//  Created by Samuel Tesla on 4/10/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "J3TelnetOption.h"

@interface J3TelnetOption (Private)

- (void) demandDisableFor: (J3TelnetQState *) state withSelector: (SEL) selector;
- (void) receivedDisableDemandForState: (J3TelnetQState *) state
                         ifAcknowledge: (SEL) acknowledge
                               ifAllow: (SEL) allow;
- (void) receivedEnableRequestForState: (J3TelnetQState *) state
                              ifAccept: (SEL) accept
                              ifReject: (SEL) reject;
- (void) requestEnableFor: (J3TelnetQState *) state withSelector: (SEL) selector;
- (void) sendDo;
- (void) sendDont;
- (void) sendWill;
- (void) sendWont;

@end

@implementation J3TelnetOption

- (void) disableHim
{
  [self demandDisableFor: &him withSelector: @selector(sendDont)];
}

- (void) disableUs
{
  [self demandDisableFor: &us withSelector: @selector(sendWont)];
}

- (J3TelnetQState) him
{
  return him;
}

- (void) setHim: (J3TelnetQState) state
{
  him = state;
}

- (id) initWithOption: (int) newOption delegate: (id <J3TelnetOptionDelegate>) object
{
  if (![super init])
    return nil;
  option = newOption;
  delegate = object;
  shouldEnable = NO;
  him = J3TelnetQNo;
  us = J3TelnetQNo;
  return self;
}

- (void) receivedDo
{
  [self receivedEnableRequestForState: &us 
                             ifAccept: @selector (sendWill) 
                             ifReject: @selector (sendWont)];  
}

- (void) receivedDont
{
  [self receivedDisableDemandForState: &us 
                        ifAcknowledge: @selector (sendWont) 
                              ifAllow: @selector (sendWill)];
}

- (void) receivedWill
{
  [self receivedEnableRequestForState: &him 
                             ifAccept: @selector (sendDo) 
                             ifReject: @selector (sendDont)];
}

- (void) receivedWont
{
  [self receivedDisableDemandForState: &him 
                        ifAcknowledge: @selector (sendDont) 
                              ifAllow: @selector (sendDo)];
}

- (void) enableHim;
{
  [self requestEnableFor: &him withSelector: @selector (sendDo)];
}

- (void) enableUs;
{
  [self requestEnableFor: &us withSelector: @selector (sendWill)];
}

- (void) setShouldEnable: (BOOL) value
{
  shouldEnable = value;
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

- (void) demandDisableFor: (J3TelnetQState *) state withSelector: (SEL) selector
{
  switch (*state)
  {
    case J3TelnetQNo:
      break;
      
    case J3TelnetQYes:
      *state = J3TelnetQWantNoEmpty;
      [self performSelector: selector];
      break;
      
    case J3TelnetQWantNoEmpty:
    case J3TelnetQWantNoOpposite:
      *state = J3TelnetQWantNoEmpty;
      break;
      
    case J3TelnetQWantYesEmpty:
    case J3TelnetQWantYesOpposite:
      *state = J3TelnetQWantYesOpposite;
      break;
  }   
}

- (void) receivedDisableDemandForState: (J3TelnetQState *) state
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

- (void) receivedEnableRequestForState: (J3TelnetQState *) state
                              ifAccept: (SEL) accept
                              ifReject: (SEL) reject
{
  switch (*state)
  {
    case J3TelnetQNo:
      if (shouldEnable)
      {
        *state = J3TelnetQYes;
        [self performSelector: accept];
      }
      else
        [self performSelector: reject];
      break;
      
    case J3TelnetQYes:
      break;
      
    case J3TelnetQWantNoEmpty:
      *state = J3TelnetQNo;
      break;
      
    case J3TelnetQWantNoOpposite:
    case J3TelnetQWantYesEmpty:
      *state = J3TelnetQYes;
      break;
      
    case J3TelnetQWantYesOpposite:
      *state = J3TelnetQWantNoEmpty;
      [self performSelector: reject];
      break;
  }
}

- (void) requestEnableFor: (J3TelnetQState *) state withSelector: (SEL) selector
{
  switch (*state)
  {
    case J3TelnetQNo:
      *state = J3TelnetQWantYesEmpty;
      [self performSelector: selector];
      break;
      
    case J3TelnetQYes:
      break;
      
    case J3TelnetQWantNoEmpty:
    case J3TelnetQWantNoOpposite:
      *state = J3TelnetQWantNoOpposite;
      break;
      
    case J3TelnetQWantYesEmpty: 
    case J3TelnetQWantYesOpposite:
      *state = J3TelnetQWantYesEmpty;
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



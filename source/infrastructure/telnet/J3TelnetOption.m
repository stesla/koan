//
// J3TelnetOption.m
//
// Copyright (c) 2010 3James Software.
//

#import "J3TelnetOption.h"

@interface J3TelnetOption (Private)

- (void) demandDisableFor: (J3TelnetQState *) state withSelector: (SEL) selector;
- (void) receivedDisableDemandForState: (J3TelnetQState *) state
                         ifAcknowledge: (SEL) acknowledge
                               ifAllow: (SEL) allow;
- (void) receivedEnableRequestForState: (J3TelnetQState *) state
                      shouldEnableFlag: (BOOL *) flag
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

- (BOOL) heIsYes
{
  return him == J3TelnetQYes;
}

- (id) initWithOption: (int) newOption delegate: (NSObject <J3TelnetOptionDelegate> *) object
{
  if (!(self = [super init]))
    return nil;
  option = newOption;
  delegate = object;
  heIsAllowed = NO;
  weAreAllowed = NO;
  him = J3TelnetQNo;
  us = J3TelnetQNo;
  return self;
}

- (void) receivedDo
{
  [self receivedEnableRequestForState: &us 
                     shouldEnableFlag: &weAreAllowed
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
                     shouldEnableFlag: &heIsAllowed
                             ifAccept: @selector (sendDo) 
                             ifReject: @selector (sendDont)];
}

- (void) receivedWont
{
  [self receivedDisableDemandForState: &him 
                        ifAcknowledge: @selector (sendDont) 
                              ifAllow: @selector (sendDo)];
}

- (void) enableHim
{
  [self requestEnableFor: &him withSelector: @selector (sendDo)];
}

- (void) enableUs
{
  [self requestEnableFor: &us withSelector: @selector (sendWill)];
}

- (void) heIsAllowedToUse: (BOOL) value
{
  heIsAllowed = value;
}

- (BOOL) weAreYes
{
  return us == J3TelnetQYes;
}

- (void) weAreAllowedToUse: (BOOL) value
{
  weAreAllowed = value;
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
                      shouldEnableFlag: (BOOL *) flag
                              ifAccept: (SEL) accept
                              ifReject: (SEL) reject
{
  switch (*state)
  {
    case J3TelnetQNo:
      if (*flag)
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



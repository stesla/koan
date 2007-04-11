//
//  J3TelnetOption.m
//  Koan
//
//  Created by Samuel Tesla on 4/10/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "J3TelnetOption.h"


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
  switch (us)
  {
    case J3TelnetQNo:
      break;
      
    case J3TelnetQYes:
      [delegate wont: option];
      [self setUs: J3TelnetQNo];
      break;
      
    case J3TelnetQWantNoOpposite:
      [self setUs: J3TelnetQWantYesEmpty];
      [delegate will: option];
      break;
      
    case J3TelnetQWantNoEmpty:
    case J3TelnetQWantYesEmpty:
    case J3TelnetQWantYesOpposite:
      [self setUs: J3TelnetQNo];
      break;
  }
}

- (void) heWill
{
}

- (void) heWont
{
  switch (him)
  {
    case J3TelnetQNo:
      break;
      
    case J3TelnetQYes:
      [delegate dont: option];
      [self setHim: J3TelnetQNo];
      break;
        
    case J3TelnetQWantNoOpposite:
      [self setHim: J3TelnetQWantYesEmpty];
      [delegate do: option];
      break;

    case J3TelnetQWantNoEmpty:
    case J3TelnetQWantYesEmpty:
    case J3TelnetQWantYesOpposite:
      [self setHim: J3TelnetQNo];
      break;
  }
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

//
// J3TelnetState.m
//
// Copyright (c) 2007 3James Software.
//

#import "J3TelnetState.h"

@class J3TelnetEngine;

static NSMutableDictionary *states;

@implementation J3TelnetState

+ (id) state
{
  J3TelnetState *result;
  
  if (!states)
    states = [[NSMutableDictionary alloc] init];
  
  if (![states objectForKey: self])
  {
    result = [[[self alloc] init] autorelease];
    [states setObject: result forKey: self];
  }
  else
  {
    result = [states objectForKey: self];
  }
  
  return result;
}

- (J3TelnetState *) parse: (uint8_t) byte forEngine: (J3TelnetEngine *) engine
{
  @throw [NSException exceptionWithName: @"SubclassResponsibility"
                                 reason: @"Subclass failed to implement -parse: forengine: "
                               userInfo: nil];
}

@end

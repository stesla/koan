//
// J3TelnetState.m
//
// Copyright (c) 2007 3James Software. All rights reserved.
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

- (J3TelnetState *) parse: (uint8_t) byte forParser: (J3TelnetEngine *) parser
{
  @throw [NSException exceptionWithName: @"SubclassResponsibility"
                                 reason: @"Subclass failed to implement -parse: forParser: "
                               userInfo: nil];
}

@end

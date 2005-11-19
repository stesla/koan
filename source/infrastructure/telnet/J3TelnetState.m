//
// J3TelnetState.m
//
// Copyright (c) 2005 3James Software
//

#import "J3TelnetState.h"

@class J3TelnetParser;

static NSMutableDictionary *states;

@implementation J3TelnetState

+ (id) state
{
  J3TelnetState *result;
  
  if (!states)
    states = [[NSMutableDictionary alloc] init];
  
  if (![states objectForKey:self])
  {
    result = [[[self alloc] init] autorelease];
    [states setObject:result forKey:self];
  }
  else
  {
    result = [states objectForKey:self];
  }
  
  return result;
}

- (J3TelnetState *) parse:(uint8_t)byte forParser:(J3TelnetParser *)parser
{
  @throw [NSException exceptionWithName:@"SubclassResponsibility"
                                 reason:@"Subclass failed to implement -parse:forParser:"
                               userInfo:nil];
}

@end

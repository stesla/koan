//
// J3TelnetState.m
//
// Copyright (c) 2007 3James Software.
//

#import "J3TelnetState.h"
#import "J3TelnetConstants.h"
#import "J3ByteSet.h"

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

+ (J3ByteSet *) telnetCommandBytes
{
  return [J3ByteSet byteSetWithBytes:
    J3TelnetEndOfRecord,
    J3TelnetEndSubnegotiation,
    J3TelnetNoOperation,
    J3TelnetDataMark,
    J3TelnetBreak,
    J3TelnetInterruptProcess,
    J3TelnetAbortOutput,
    J3TelnetAreYouThere,
    J3TelnetEraseCharacter,
    J3TelnetEraseLine,
    J3TelnetGoAhead,
    J3TelnetBeginSubnegotiation,
    J3TelnetWill,
    J3TelnetWont,
    J3TelnetDo,
    J3TelnetDont,
    J3TelnetInterpretAsCommand,
    -1];
}

- (J3TelnetState *) parse: (uint8_t) byte forEngine: (J3TelnetEngine *) engine
{
  @throw [NSException exceptionWithName: @"SubclassResponsibility"
                                 reason: @"Subclass failed to implement -parse: forengine: "
                               userInfo: nil];
}

@end

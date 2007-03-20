//
// J3TelnetInterpretAsCommandState.m
//
// Copyright (c) 2005, 2007 3James Software
//

#import "J3TelnetConstants.h"
#import "J3TelnetDoState.h"
#import "J3TelnetDontState.h"
#import "J3TelnetInterpretAsCommandState.h"
#import "J3TelnetParser.h"
#import "J3TelnetState.h"
#import "J3TelnetTextState.h"
#import "J3TelnetWillState.h"
#import "J3TelnetWontState.h"

@implementation J3TelnetInterpretAsCommandState

- (J3TelnetState *) parse:(uint8_t)byte forParser:(J3TelnetParser *)parser
{
  switch (byte)
  {
    case J3TelnetDo:
      return [J3TelnetDoState state];
      break;
      
    case J3TelnetDont:
      return [J3TelnetDontState state];
      break;
    
    case J3TelnetWill:
      return [J3TelnetWillState state];
      break;
    
    case J3TelnetWont:
      return [J3TelnetWontState state];
      break;

    case J3TelnetInterpretAsCommand:
      [parser bufferInputByte:J3TelnetInterpretAsCommand]; 
      // Fallthrough.
      
    default:
      return [J3TelnetTextState state];
  }
}

@end

//
//  J3TelnetOptionTests.m
//  Koan
//
//  Created by Samuel Tesla on 4/10/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "J3TelnetConstants.h"
#import "J3TelnetOptionTests.h"

#define DO 0x01
#define DONT 0x02
#define WILL 0x04
#define WONT 0x08

#define QSTATES 6
typedef int QMethodTable[QSTATES][3];

@interface J3TelnetOptionTests (Private)

- (void) assertQMethodTable: (QMethodTable) table forSelector: (SEL) selector;
- (void) assertWhenSelector: (SEL) selector
          isCalledFromState: (J3TelnetQState) startState
        theResultingStateIs: (J3TelnetQState) endState
                   andCalls: (char) flags;
- (void) clearFlags;
- (NSString *) qStateName: (J3TelnetQState) state;

@end

#pragma mark -

@implementation J3TelnetOptionTests

- (void) setUp
{
  [super setUp];
  [self clearFlags];
  option = [[J3TelnetOption alloc] initWithOption: J3TelnetOptionEcho delegate: self];
}

- (void) tearDown
{
  [option release];
  [super tearDown];
}

- (void) testHeWont
{
  QMethodTable table = {
    {J3TelnetQNo,               J3TelnetQNo,            0},
    {J3TelnetQYes,              J3TelnetQNo,            DONT},
    {J3TelnetQWantNoEmpty,      J3TelnetQNo,            0},
    {J3TelnetQWantNoOpposite,   J3TelnetQWantYesEmpty,  DO},
    {J3TelnetQWantYesEmpty,     J3TelnetQNo,            0},
    {J3TelnetQWantYesOpposite,  J3TelnetQNo,            0},
  };
  [self assertQMethodTable: table forSelector: @selector(heWont)];
}

#pragma mark -
#pragma mark J3TelnetOptionDelegate protocol

- (void) do: (uint8_t) option
{
  flags = flags | DO;
}

- (void) dont: (uint8_t) option
{
  flags = flags | DONT;
}

- (void) will: (uint8_t) option
{
  flags = flags | WILL;
}

- (void) wont: (uint8_t) option
{
  flags = flags | WONT;
}

@end

#pragma mark -

@implementation J3TelnetOptionTests (Private)

- (void) assertQMethodTable: (QMethodTable) table forSelector: (SEL) selector
{
  for (unsigned i = 0; i < QSTATES; ++i)
  {
    [self assertWhenSelector: selector
           isCalledFromState: table[i][0]
         theResultingStateIs: table[i][1]
                    andCalls: table[i][2]];
  }  
}

- (void) assertWhenSelector: (SEL) selector
          isCalledFromState: (J3TelnetQState) startState
        theResultingStateIs: (J3TelnetQState) endState
                   andCalls: (char) expectedFlags;
{
  NSString *message = [self qStateName: startState];
  [self clearFlags];
  [option setHim: startState];
  [option performSelector: selector];
  [self assertInt: [option him] equals: endState message: [NSString stringWithFormat: @"%@ ending state",message]];
  [self assertInt: flags equals: expectedFlags message: [NSString stringWithFormat: @"%@ flags",message]];
}

- (void) clearFlags
{
  flags = 0;
}

- (NSString *) qStateName: (J3TelnetQState) state
{
  switch (state)
  {
    case J3TelnetQNo:
      return @"J3TelnetQNo";
    case J3TelnetQYes:
      return @"J3TelnetQYes";
    case J3TelnetQWantNoEmpty:
      return @"J3TelnetQWantNoEmpty";
    case J3TelnetQWantNoOpposite:
      return @"J3TelnetQWantNoOpposite";
    case J3TelnetQWantYesEmpty:
      return @"J3TelnetQWantYesEmpty";
    case J3TelnetQWantYesOpposite:
      return @"J3TelnetQWantYesOpposite";
    default:
      return @"Unknown";
  }
}

@end

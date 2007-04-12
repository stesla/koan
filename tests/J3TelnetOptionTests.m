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

- (void) assertQMethodTable: (QMethodTable) table forSelector: (SEL) selector forHimOrUs: (SEL) himOrUs;
- (void) assertWhenSelector: (SEL) selector
          isCalledFromState: (J3TelnetQState) startState
                 forHimOrUs: (SEL) himOrUs
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

- (void) testReceivedWont
{
  QMethodTable table = {
    {J3TelnetQNo,               J3TelnetQNo,            0},
    {J3TelnetQYes,              J3TelnetQNo,            DONT},
    {J3TelnetQWantNoEmpty,      J3TelnetQNo,            0},
    {J3TelnetQWantNoOpposite,   J3TelnetQWantYesEmpty,  DO},
    {J3TelnetQWantYesEmpty,     J3TelnetQNo,            0},
    {J3TelnetQWantYesOpposite,  J3TelnetQNo,            0},
  };
  [self assertQMethodTable: table forSelector: @selector (receivedWont) forHimOrUs: @selector (him)];
}

- (void) testReceivedDont
{
  QMethodTable table = {
    {J3TelnetQNo,               J3TelnetQNo,            0},
    {J3TelnetQYes,              J3TelnetQNo,            WONT},
    {J3TelnetQWantNoEmpty,      J3TelnetQNo,            0},
    {J3TelnetQWantNoOpposite,   J3TelnetQWantYesEmpty,  WILL},
    {J3TelnetQWantYesEmpty,     J3TelnetQNo,            0},
    {J3TelnetQWantYesOpposite,  J3TelnetQNo,            0},
  };
  [self assertQMethodTable: table forSelector: @selector (receivedDont) forHimOrUs: @selector (us)];
}

- (void) testReceivedWillButWeDoNotWantTo
{
  [option setShouldEnable: NO];
  QMethodTable table = {
    {J3TelnetQNo,               J3TelnetQNo,            DONT},
    {J3TelnetQYes,              J3TelnetQYes,           0},
    {J3TelnetQWantNoEmpty,      J3TelnetQNo,            0},   // error
    {J3TelnetQWantNoOpposite,   J3TelnetQYes,           0},   // error
    {J3TelnetQWantYesEmpty,     J3TelnetQYes,           0},
    {J3TelnetQWantYesOpposite,  J3TelnetQWantNoEmpty,   DONT},
  };
  [self assertQMethodTable: table forSelector: @selector (receivedWill) forHimOrUs: @selector (him)];  
}

- (void) testReceivedWillAndWeDoWantTo
{
  [option setShouldEnable: YES];
  QMethodTable table = {
    {J3TelnetQNo,               J3TelnetQYes,           DO},
    {J3TelnetQYes,              J3TelnetQYes,           0},
    {J3TelnetQWantNoEmpty,      J3TelnetQNo,            0},   // error
    {J3TelnetQWantNoOpposite,   J3TelnetQYes,           0},   // error
    {J3TelnetQWantYesEmpty,     J3TelnetQYes,           0},
    {J3TelnetQWantYesOpposite,  J3TelnetQWantNoEmpty,   DONT},
  };
  [self assertQMethodTable: table forSelector: @selector (receivedWill) forHimOrUs: @selector (him)];    
}

- (void) testReceivedDoAndWeDoNotWantTo
{
  [option setShouldEnable: NO];
  QMethodTable table = {
    {J3TelnetQNo,               J3TelnetQNo,            WONT},
    {J3TelnetQYes,              J3TelnetQYes,           0},
    {J3TelnetQWantNoEmpty,      J3TelnetQNo,            0},   // error
    {J3TelnetQWantNoOpposite,   J3TelnetQYes,           0},   // error
    {J3TelnetQWantYesEmpty,     J3TelnetQYes,           0},
    {J3TelnetQWantYesOpposite,  J3TelnetQWantNoEmpty,   WONT},
  };
  [self assertQMethodTable: table forSelector: @selector (receivedDo) forHimOrUs: @selector (us)];    
}

- (void) testReceivedDoAndWeDoWantTo
{
  [option setShouldEnable: YES];
  QMethodTable table = {
    {J3TelnetQNo,               J3TelnetQYes,           WILL},
    {J3TelnetQYes,              J3TelnetQYes,           0},
    {J3TelnetQWantNoEmpty,      J3TelnetQNo,            0},   // error
    {J3TelnetQWantNoOpposite,   J3TelnetQYes,           0},   // error
    {J3TelnetQWantYesEmpty,     J3TelnetQYes,           0},
    {J3TelnetQWantYesOpposite,  J3TelnetQWantNoEmpty,   WONT},
  };
  [self assertQMethodTable: table forSelector: @selector (receivedDo) forHimOrUs: @selector (us)];    
}

- (void) testEnableHimWithQueue
{
  QMethodTable table = {
    {J3TelnetQNo,               J3TelnetQWantYesEmpty,    DO},
    {J3TelnetQYes,              J3TelnetQYes,             0},   // error
    {J3TelnetQWantNoEmpty,      J3TelnetQWantNoOpposite,  0},   
    {J3TelnetQWantNoOpposite,   J3TelnetQWantNoOpposite,  0},   // error
    {J3TelnetQWantYesEmpty,     J3TelnetQWantYesEmpty,    0},   // error
    {J3TelnetQWantYesOpposite,  J3TelnetQWantYesEmpty,    0},
  };
  [self assertQMethodTable: table forSelector: @selector (enableHim) forHimOrUs: @selector (him)];    
}

- (void) testEnableUsWithQueue
{
  QMethodTable table = {
    {J3TelnetQNo,               J3TelnetQWantYesEmpty,    WILL},
    {J3TelnetQYes,              J3TelnetQYes,             0},   // error
    {J3TelnetQWantNoEmpty,      J3TelnetQWantNoOpposite,  0},   
    {J3TelnetQWantNoOpposite,   J3TelnetQWantNoOpposite,  0},   // error
    {J3TelnetQWantYesEmpty,     J3TelnetQWantYesEmpty,    0},   // error
    {J3TelnetQWantYesOpposite,  J3TelnetQWantYesEmpty,    0},
  };
  [self assertQMethodTable: table forSelector: @selector (enableUs) forHimOrUs: @selector (us)];    
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

- (void) assertQMethodTable: (QMethodTable) table forSelector: (SEL) selector forHimOrUs: (SEL) himOrUs
{
  for (unsigned i = 0; i < QSTATES; ++i)
  {
    [self assertWhenSelector: selector
           isCalledFromState: table[i][0]
                  forHimOrUs: himOrUs
         theResultingStateIs: table[i][1]
                    andCalls: table[i][2]];
  }  
}

- (void) assertWhenSelector: (SEL) selector
          isCalledFromState: (J3TelnetQState) startState
                 forHimOrUs: (SEL) himOrUs
        theResultingStateIs: (J3TelnetQState) endState
                   andCalls: (char) expectedFlags;
{
  NSString *message = [self qStateName: startState];
  [self clearFlags];
  if (himOrUs == @selector (him))
    [option setHim: startState];
  else
    [option setUs: startState];
  [option performSelector: selector];
  [self assertInt: (int) [option performSelector: himOrUs] equals: endState message: [NSString stringWithFormat: @"%@ ending state",message]];
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

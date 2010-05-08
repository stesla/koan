//
// J3TelnetOptionTests.h
//
// Copyright (c) 2010 3James Software.
//

#import <J3Testing/J3TestCase.h>
#import "J3TelnetOption.h"

@interface J3TelnetOptionTests : J3TestCase <J3TelnetOptionDelegate>
{
  J3TelnetOption *option;
  char flags;
}

@end

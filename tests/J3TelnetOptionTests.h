//
//  J3TelnetOptionTests.h
//  Koan
//
//  Created by Samuel Tesla on 4/10/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <J3Testing/J3TestCase.h>
#import "J3TelnetOption.h"

@interface J3TelnetOptionTests : J3TestCase <J3TelnetOptionDelegate>
{
  J3TelnetOption *option;
  char flags;
}

@end

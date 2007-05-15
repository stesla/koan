//
//  J3TelnetEngineTests.h
//  Koan
//
//  Created by Samuel Tesla on 4/5/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <J3Testing/J3TestCase.h>
#import "J3TelnetEngine.h"

@interface J3TelnetEngineTests : J3TestCase <J3TelnetEngineDelegate>
{
  J3TelnetEngine *engine;
  NSMutableData *inputBuffer;
  NSMutableData *outputBuffer;
}

@end

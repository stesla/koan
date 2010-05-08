//
// J3TelnetEngineTests.h
//
// Copyright (c) 2010 3James Software.
//

#import <J3Testing/J3TestCase.h>
#import "J3TelnetEngine.h"

@interface J3TelnetEngineTests : J3TestCase <J3TelnetEngineDelegate>
{
  J3TelnetEngine *engine;
  NSMutableData *readBuffer;
  NSMutableData *outputBuffer;
  NSMutableArray *dataSegments;
}

@end

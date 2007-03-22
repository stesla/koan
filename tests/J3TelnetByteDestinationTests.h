//
//  J3TelnetByteDestination.h
//
// Copyright (c) 2007 3James Software
//

#import <J3Testing/J3TestCase.h>
#import "infrastructure/telnet/J3TelnetByteDestination.h"

@protocol J3ByteDestination;

@interface J3TelnetByteDestinationTests : J3TestCase <J3ByteDestination>
{
  J3TelnetByteDestination *destination;
  BOOL hasSpaceAvailable;
  int maxBytesPerWrite;
  int numberOfWrites;
  NSMutableData *output;
}

@end

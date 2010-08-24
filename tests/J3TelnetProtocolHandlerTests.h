//
// J3TelnetProtocolHandlerTests.h
//
// Copyright (c) 2010 3James Software.
//

#import <J3Testing/J3TestCase.h>
#import "J3TelnetProtocolHandler.h"

@class J3ProtocolStack;

@interface J3TelnetProtocolHandlerTests : J3TestCase <J3TelnetProtocolHandlerDelegate>
{
  J3ProtocolStack *protocolStack;
  J3TelnetProtocolHandler *protocolHandler;
  NSMutableData *mockSocketData;
}

@end

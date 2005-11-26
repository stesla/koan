//
// J3SocksConstants.h
//
// Copyright (c) 2005 3James Software
//

#import <Cocoa/Cocoa.h>

enum J3SocksMiscellaneous
{
  J3SocksVersion = 0x05
};

typedef enum J3SocksMethod
{
  J3SocksNoAuthentication = 0x00,
  J3SocksGssApi = 0x01,
  J3SocksUsernamePassword = 0x02,
  J3SocksNoAcceptableMethods = 0xFF
} J3SocksMethod;

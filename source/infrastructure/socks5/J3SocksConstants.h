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

typedef enum J3SocksReply
{
  J3SocksSuccess = 0x00,
  J3SocksGeneralServerFailure = 0x01,
  J3SocksConnectionNotAllowed = 0x02,
  J3SocksNetworkUnreachable = 0x03,
  J3SocksHostUnreachable = 0x04,
  J3SocksConnectionRefused = 0x05,
  J3SocksTimeToLiveExpired = 0x06,
  J3SocksCommandNotSupported = 0x07,
  J3SocksAddressTypeNotSupported = 0x08
} J3SocksReply;
//
//  J3Socks5Constants.h
//  Koan
//
//  Created by Samuel Tesla on 11/22/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

enum J3Socks5Miscellaneous
{
  J3Socks5Version = 0x05
};

typedef enum J3Socks5Method
{
  J3Socks5NoAuthentication = 0x00,
  J3Socks5GssApi = 0x01,
  J3Socks5UsernamePassword = 0x02,
  J3Socks5NoAcceptableMethods = 0xFF
} J3Socks5Method;
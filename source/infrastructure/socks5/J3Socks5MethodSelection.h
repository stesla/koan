//
//  J3Socks5MethodSelection.h
//  Koan
//
//  Created by Samuel Tesla on 11/22/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "J3Buffer.h"
#import "J3Socks5Constants.h"

@interface J3Socks5MethodSelection : NSObject 
{
  NSMutableData * methods;
}

- (void) addMethod:(J3Socks5Method)method;
- (void) appendToBuffer:(id <J3Buffer>)buffer;

@end

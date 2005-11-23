//
//  J3SocksMethodSelection.h
//  Koan
//
//  Created by Samuel Tesla on 11/22/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "J3Buffer.h"
#import "J3SocksConstants.h"

@interface J3SocksMethodSelection : NSObject 
{
  NSMutableData * methods;
}

- (void) addMethod:(J3SocksMethod)method;
- (void) appendToBuffer:(id <J3Buffer>)buffer;

@end

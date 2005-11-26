//
// J3SocksMethodSelection.h
//
// Copyright (c) 2005 3James Software
//

#import <Cocoa/Cocoa.h>
#import "J3Buffer.h"
#import "J3SocksConstants.h"

@interface J3SocksMethodSelection : NSObject 
{
  NSMutableData *methods;
}

- (void) addMethod:(J3SocksMethod)method;
- (void) appendToBuffer:(id <J3Buffer>)buffer;

@end

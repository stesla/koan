//
// J3SocksMethodSelection.h
//
// Copyright (c) 2005 3James Software
//

#import <Cocoa/Cocoa.h>
#import "J3Buffer.h"
#import "J3SocksConstants.h"

@protocol J3ByteSource;

@interface J3SocksMethodSelection : NSObject 
{
  NSMutableData *methods;
  J3SocksMethod selectedMethod;
}

- (void) addMethod:(J3SocksMethod)method;
- (void) appendToBuffer:(id <J3Buffer>)buffer;
- (J3SocksMethod) method;
- (void) parseResponseFromByteSource:(id <J3ByteSource>)byteSource;

@end

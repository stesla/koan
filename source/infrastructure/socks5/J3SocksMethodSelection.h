//
// J3SocksMethodSelection.h
//
// Copyright (c) 2010 3James Software.
//

#import <Cocoa/Cocoa.h>
#import "J3SocksConstants.h"

@protocol J3ByteSource;
@protocol J3WriteBuffer;

@interface J3SocksMethodSelection : NSObject
{
  NSMutableData *methods;
  J3SocksMethod selectedMethod;
}

+ (id) socksMethodSelection;

- (void) addMethod: (J3SocksMethod) method;
- (void) appendToBuffer: (NSObject <J3WriteBuffer> *) buffer;
- (J3SocksMethod) method;
- (void) parseResponseFromByteSource: (NSObject <J3ByteSource> *) byteSource;

@end

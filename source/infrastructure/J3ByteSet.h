//
//  J3ByteSet.h
//  Koan
//
//  Created by Samuel on 4/19/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface J3ByteSet : NSObject 
{
  BOOL contains[UINT8_MAX];
}

+ (id) byteSet;
+ (id) byteSetWithBytes: (int) first, ...;

- (id) initWithFirstByte: (int) first remainingBytes: (va_list) bytes;

- (void) addByte: (uint8_t) byte;
- (void) addBytes: (uint8_t) first, ...;
- (void) addFirstByte: (int) first remainingBytes: (va_list) bytes;
- (BOOL) containsByte: (uint8_t) byte;

@end

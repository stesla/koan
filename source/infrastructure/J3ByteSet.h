//
// J3ByteSet.h
//
// Copyright (c) 2010 3James Software.
//

#import <Cocoa/Cocoa.h>

@interface J3ByteSet : NSObject 
{
  BOOL contains[UINT8_MAX];
}

+ (id) byteSet;
+ (id) byteSetWithBytes: (int) first, ...;
+ (id) byteSetWithBytes: (const uint8_t *) bytes length: (size_t) length;

- (id) initWithBytes: (const uint8_t *) bytes length: (size_t) length;
- (id) initWithFirstByte: (int) first remainingBytes: (va_list) bytes;

- (void) addByte: (uint8_t) byte;
- (void) addBytes: (uint8_t) first, ...;
- (void) addFirstByte: (int) first remainingBytes: (va_list) bytes;
- (BOOL) containsByte: (uint8_t) byte;
- (NSData *) dataValue;
- (J3ByteSet *) inverseSet;
- (void) removeByte: (uint8_t) byte;

@end

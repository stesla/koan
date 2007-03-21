//
// J3Buffer.h
//
// Copyright (c) 2005, 2006 3James Software
//

#import <Cocoa/Cocoa.h>

@protocol J3Buffer

- (void) append: (uint8_t)byte;
- (void) appendBytes: (const void *)bytes length: (unsigned)length;
- (void) appendLine: (NSString *)line;
- (void) appendString: (NSString *)string;
- (const void *)bytes;
- (void) clear;
- (BOOL) isEmpty;
- (unsigned) length;
- (NSData *) dataValue;
- (NSString *) stringValue;

@end

#pragma mark -

@interface J3Buffer : NSObject <J3Buffer>
{
  NSMutableData *data;
}

+ (id) buffer;

- (void) removeDataNotInRange: (NSRange)range;
- (void) removeDataUpTo: (unsigned)position;
- (void) setDataValue: (NSData *)newDataValue;

@end

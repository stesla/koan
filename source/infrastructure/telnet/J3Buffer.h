//
// J3Buffer.h
//
// Copyright (c) 2005 3James Software
//

#import <Cocoa/Cocoa.h>

@protocol J3Buffer

- (void) append:(uint8_t)byte;
- (void) appendLine:(NSString *)line;
- (void) appendString:(NSString *)string;
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

- (void) setDataValue:(NSData *)newDataValue;

@end

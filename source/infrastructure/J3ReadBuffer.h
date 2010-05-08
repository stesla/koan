//
// J3ReadBuffer.h
//
// Copyright (c) 2010 3James Software.
//

#import <Cocoa/Cocoa.h>

@protocol J3ReadBuffer

- (void) appendByte: (uint8_t) byte;
- (void) appendData: (NSData *) data;
- (void) clear;
- (BOOL) isEmpty;
- (unsigned) length;

- (NSData *) dataByConsumingBuffer;
- (NSData *) dataByConsumingBytesToIndex: (unsigned) index;
- (NSData *) dataValue;

- (NSString *) ASCIIStringByConsumingBuffer;
- (NSString *) ASCIIStringValue;

- (NSString *) stringByConsumingBufferWithEncoding: (NSStringEncoding) encoding;
- (NSString *) stringValueWithEncoding: (NSStringEncoding) encoding;

@end

#pragma mark -

@interface J3ReadBuffer : NSObject <J3ReadBuffer>
{
  NSMutableData *dataBuffer;
}

+ (J3ReadBuffer *) buffer;

@end

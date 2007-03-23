//
// J3WriteBuffer.h
//
// Copyright (c) 2005, 2006, 2007 3James Software
//

#import <Cocoa/Cocoa.h>

@protocol J3WriteBuffer

- (void) appendByte: (uint8_t) byte;
- (void) appendBytes: (const uint8_t *) bytes length: (unsigned) length;
- (void) appendCharacter: (unichar) character;
- (void) appendLine: (NSString *) line;
- (void) appendString: (NSString *) string;
- (const uint8_t *) bytes;
- (void) clear;
- (void) flush;
- (BOOL) isEmpty;
- (unsigned) length;

// Both of these are pretty expensive in J3WriteBuffer currently.
- (NSData *) dataValue;
- (NSString *) stringValue;

@end

#pragma mark -

@interface J3WriteBufferException : NSException

@end

#pragma mark -

@protocol J3ByteDestination;

@interface J3WriteBuffer : NSObject <J3WriteBuffer>
{
  NSObject <J3ByteDestination> *destination;
  
  NSMutableArray *blocks;
  id lastBlock;
  BOOL lastBlockIsBinary;
  unsigned totalLength;
}

+ (id) buffer;

- (void) setByteDestination: (NSObject <J3ByteDestination> *) object;

@end

//
// J3Buffer.h
//
// Copyright (c) 2005, 2006, 2007 3James Software
//

#import <Cocoa/Cocoa.h>

@protocol J3Buffer

- (void) appendByte: (uint8_t) byte;
- (void) appendBytes: (const uint8_t *) bytes length: (unsigned) length;
- (void) appendLine: (NSString *) line;
- (void) appendString: (NSString *) string;
- (const void *) bytes;
- (void) clear;
- (BOOL) isEmpty;
- (unsigned) length;

// Both of these are pretty expensive.
- (NSData *) dataValue;
- (NSString *) stringValue;

@end

#pragma mark -

@interface J3Buffer : NSObject <J3Buffer>
{
  NSMutableArray *blocks;
  id lastBlock;
  unsigned totalLength;
  BOOL lastBlockIsBinary;
}

+ (id) buffer;

- (void) removeDataUpTo: (unsigned) position;

@end

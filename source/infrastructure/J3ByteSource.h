//
// J3ByteSource.h
//
// Copyright (c) 2007 3James Software. All rights reserved.
//

@protocol J3ByteSource

- (BOOL) hasDataAvailable;
- (NSData *) readUpToLength: (unsigned) length;

@end

@interface J3ByteSource : NSObject

+ (void) ensureBytesReadFromSource: (id <J3ByteSource>) byteSource intoBuffer: (uint8_t *) buffer ofLength: (unsigned) length;

@end

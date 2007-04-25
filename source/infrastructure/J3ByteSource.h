//
// J3ByteSource.h
//
// Copyright (c) 2007 3James Software.
//

@protocol J3ByteSource

- (unsigned) availableBytes;
- (BOOL) hasDataAvailable;
- (NSData *) readUpToLength: (size_t) length;

@end

@interface J3ByteSource : NSObject

+ (void) ensureBytesReadFromSource: (id <J3ByteSource>) byteSource intoBuffer: (uint8_t *) buffer ofLength: (size_t) length;

@end

//
// J3ByteSource.h
//
// Copyright (c) 2006 3James Software
//

@protocol J3ByteSource

- (BOOL) hasDataAvailable;
- (NSData *) readUpToLength: (unsigned) length;

@end

@interface J3ByteSource : NSObject

+ (void) ensureBytesReadFromSource: (id <J3ByteSource>) byteSource intoBuffer: (uint8_t *) buffer ofLength: (unsigned) length;

@end

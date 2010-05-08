//
// J3ByteSource.h
//
// Copyright (c) 2010 3James Software.
//

@protocol J3ByteSource

- (unsigned) availableBytes;
- (BOOL) hasDataAvailable;
- (void) poll;
- (NSData *) readExactlyLength: (size_t) length;
- (NSData *) readUpToLength: (size_t) length;

@end

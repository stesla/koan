//
// J3ByteSource.h
//
// Copyright (c) 2007 3James Software.
//

@protocol J3ByteSource

- (unsigned) availableBytes;
- (BOOL) hasDataAvailable;
- (NSData *) readExactlyLength: (size_t) length;
- (NSData *) readUpToLength: (size_t) length;
- (void) poll;

@end

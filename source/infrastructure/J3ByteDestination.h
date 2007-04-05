//
// J3ByteDestination.h
//
// Copyright (c) 2007 3James Software.
//

@protocol J3ByteDestination

- (BOOL) hasSpaceAvailable;
- (ssize_t) write: (NSData *) data;

@end

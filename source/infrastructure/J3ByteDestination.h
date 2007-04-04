//
// J3ByteDestination.h
//
// Copyright (c) 2007 3James Software. All rights reserved.
//

@protocol J3ByteDestination

- (BOOL) hasSpaceAvailable;
- (unsigned) write: (NSData *) data;

@end

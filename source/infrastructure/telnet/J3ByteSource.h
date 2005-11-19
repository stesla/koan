//
// J3ByteSource.h
//
// Copyright (c) 2005 3James Software
//

@protocol J3ByteSource

- (BOOL) hasDataAvailable;
- (unsigned) read:(uint8_t *)buffer maxLength:(unsigned)length;

@end

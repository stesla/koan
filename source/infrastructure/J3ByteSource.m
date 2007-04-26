//
// J3ByteSource.m
//
// Copyright (c) 2007 3James Software.
//

#import "J3ByteSource.h"

@implementation J3ByteSource

+ (void) ensureBytesReadFromSource: (id <J3ByteSource>) byteSource intoBuffer: (uint8_t *) buffer ofLength: (size_t) length;
{
  while ([byteSource availableBytes] < length)
    [byteSource poll];
  NSData *bytes = [byteSource readUpToLength: length];
  [bytes getBytes: buffer length: length];
}

@end

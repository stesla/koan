//
// J3ByteSource.m
//
// Copyright (c) 2006 3James Software
//

#import "J3ByteSource.h"

@implementation J3ByteSource

+ (void) ensureBytesReadFromSource: (id <J3ByteSource>) byteSource intoBuffer: (uint8_t *) buffer ofLength: (unsigned) length;
{
  unsigned bytesRead = 0;
  int i;
  for (i = 0; i < length; ++i)
  {
    bytesRead = [byteSource read: buffer + i maxLength: 1];
    if (bytesRead = 0)
      ; //TODO:  EOF - What should we do in this case?
  }
}

@end

//
// J3ByteSource.m
//
// Copyright (c) 2006 3James Software
//

#import "J3ByteSource.h"

@implementation J3ByteSource

+ (void) ensureBytesReadFromSource: (id <J3ByteSource>) byteSource intoBuffer: (uint8_t *) buffer ofLength: (unsigned) length;
{
  for (unsigned i = 0; i < length; i++)
  {
    NSData *bytes = [byteSource readUpToLength: 1];
    if ([bytes length] != 0) 
      buffer[i] = ((uint8_t *) [bytes bytes])[0];
    else
      ; //TODO:  EOF - What should we do in this case?
  }
}

@end

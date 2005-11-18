//
//  J3WriteBuffer.m
//  Koan
//
//  Created by Samuel Tesla on 11/15/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "J3WriteBuffer.h"

@implementation J3WriteBufferException
@end

@implementation J3WriteBuffer
- (void) setByteDestination:(id <NSObject, J3ByteDestination>)object;
{
  [object retain];
  [destination release];
  destination = object;
}

- (void) write;
{
  const uint8_t * bytes;
  unsigned int bytesWritten; 
  NSRange range;
  
  if (!destination)
    @throw [J3WriteBufferException exceptionWithName:@"" reason:@"Must provide destination" userInfo:nil];
  bytes = [buffer bytes];
  bytesWritten = [destination writeBytes:bytes length:[buffer length]];
  range.location = bytesWritten;
  range.length = [buffer length] - bytesWritten;
  [self setBuffer:[buffer subdataWithRange:range]];
}

- (void) writeUnlessEmpty;
{
  if ([self isEmpty])
    return;
  [self write];
}
@end

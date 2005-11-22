//
// J3WriteBuffer.m
//
// Copyright (c) 2005 3James Software
//

#import "J3WriteBuffer.h"

@implementation J3WriteBufferException

@end

@interface J3WriteBuffer (Private)

- (void) write;

@end

#pragma mark -

@implementation J3WriteBuffer

- (void) setByteDestination:(id <NSObject, J3ByteDestination>)object
{
  [object retain];
  [destination release];
  destination = object;
}

#pragma mark -
#pragma mark Overrides

- (void) flush
{
  while (![self isEmpty])
    [self write];
}

@end

#pragma mark -

@implementation J3WriteBuffer (Private)

- (void) write
{
  unsigned bytesWritten; 
  NSRange range;
  
  if (!destination)
    @throw [J3WriteBufferException exceptionWithName:@"" reason:@"Must provide destination" userInfo:nil];
  
  bytesWritten = [destination write:(uint8_t *) [self bytes] length:[self length]];
  range.location = bytesWritten;
  range.length = [self length] - bytesWritten;
  [self setDataValue:[[self dataValue] subdataWithRange:range]];
}

@end
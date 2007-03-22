//
// J3WriteBuffer.m
//
// Copyright (c) 2005, 2006, 2007 3James Software
//

#import "J3WriteBuffer.h"

@implementation J3WriteBufferException

@end

#pragma mark -

@interface J3WriteBuffer (Private)

- (void) write;

@end

#pragma mark -

@implementation J3WriteBuffer

- (void) setByteDestination: (NSObject <J3ByteDestination> *) object
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

#pragma mark -
#pragma mark J3ByteDestination protocol

- (BOOL) hasSpaceAvailable;
{
  return YES;
}

- (unsigned) write: (const uint8_t *) bytes length: (unsigned) length;
{
  [self appendBytes: bytes length: length];
  [self flush];
  return length;
}

@end

#pragma mark -

@implementation J3WriteBuffer (Private)

- (void) write
{
  unsigned bytesWritten; 
  
  if (!destination)
    @throw [J3WriteBufferException exceptionWithName: @"" reason: @"Must provide destination" userInfo: nil];
  
  bytesWritten = [destination write: (uint8_t *) [self bytes] length: [self length]];
  [self removeDataUpTo: bytesWritten];
}

@end
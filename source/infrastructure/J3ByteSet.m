//
//  J3ByteSet.m
//  Koan
//
//  Created by Samuel on 4/19/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "J3ByteSet.h"

@implementation J3ByteSet

+ (id) byteSet
{
  return [[[self alloc] init] autorelease];
}

+ (id) byteSetWithBytes: (int) first, ...
{
  va_list args;
  va_start (args, first);
  id result = [[[self alloc] initWithFirstByte: first remainingBytes: args] autorelease];
  va_end (args);
  return result;
}

- (void) addByte: (uint8_t) byte;
{
  if (!contains[byte])
    contains[byte] = YES;
}

- (void) addBytes: (uint8_t) first, ...;
{
  va_list args;
  va_start (args, first);
  [self addFirstByte: first remainingBytes: args];
  va_end (args);
}

- (void) addFirstByte: (int) first remainingBytes: (va_list) bytes
{
  int current;

  [self addByte: first];
  while ((current = va_arg (bytes, int)) != -1)
    contains[current] = YES;  
}

- (BOOL) containsByte: (uint8_t) byte
{
  return contains[byte];
}

- (id) init
{
  if (![super init])
    return nil;
  for (unsigned i = 0; i <= UINT8_MAX; ++i)
    contains[i] = NO;
  return self;
}

- (id) initWithFirstByte: (int) first remainingBytes: (va_list) bytes
{
  id result = [self init];
  if (!result)
    return nil;
  [result addFirstByte: first remainingBytes: bytes];
  return result;
}

@end

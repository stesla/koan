//
// NSObject (BetterHashing).m
//
// Copyright (c) 2004, 2005 3James Software
//
// This file is in the public domain.
//

@implementation NSObject (BetterHashing)

- (unsigned) hash
{
  return (((unsigned) self >> 4) | (unsigned) self << (32 - 4));
}

@end

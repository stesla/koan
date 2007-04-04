//
// NSObject (BetterHashing).m
//
// Copyright (c) 2007 3James Software. All rights reserved.
//
// This file is in the public domain.
//

@implementation NSObject (BetterHashing)

- (unsigned) hash
{
  return (((unsigned) self >> 4) | (unsigned) self << (32 - 4));
}

@end

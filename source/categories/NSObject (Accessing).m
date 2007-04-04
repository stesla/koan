//
// NSObject (Accessing).m
//
// Copyright (c) 2007 3James Software. All rights reserved.
//
// This file is in the public domain.
//

#import "NSObject (Accessing).h"

@implementation NSObject (Accessing)

- (void) at: (id *) field put: (id) value;
{
  if (*field == value)
    return;
  [*field release];
  *field = [value retain];
}

@end

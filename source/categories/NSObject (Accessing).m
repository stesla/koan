//
// NSObject (Accessing).m
//
// Copyright (c) 2005 3James Software
//
// This file is in the public domain.
//

#import "NSObject (Accessing).h"

@implementation NSObject (Accessing)

- (void) at:(id *)field put:(id)value;
{
  [value retain];
  [*field release];
  *field = value;
}

@end

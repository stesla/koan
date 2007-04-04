//
// NSURL (Allocating).m
//
// Copyright (c) 2007 3James Software. All rights reserved.
//
// This file is in the public domain.
//

#import "NSURL (Allocating).h"

@implementation NSURL (Allocating)

+ (NSURL *) URLWithScheme: (NSString *) scheme host: (NSString *) host path: (NSString *) path
{
  return [[[self alloc] initWithScheme: scheme host: host path: path] autorelease];
}

@end

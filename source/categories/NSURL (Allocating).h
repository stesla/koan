//
// NSURL (Allocating).h
//
// Copyright (c) 2007 3James Software. All rights reserved.
//
// This file is in the public domain.
//

#import <Cocoa/Cocoa.h>

@interface NSURL (Allocating)

+ (NSURL *) URLWithScheme: (NSString *) scheme host: (NSString *) host path: (NSString *) path;

@end

//
// NSURL (Allocating).h
//
// Copyright (c) 2004, 2005 3James Software
//
// This file is in the public domain.
//

#import <Cocoa/Cocoa.h>

@interface NSURL (Allocating)

+ (NSURL *) URLWithScheme:(NSString *)scheme host:(NSString *)host path:(NSString *)path;

@end

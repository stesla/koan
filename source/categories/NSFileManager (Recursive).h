//
// NSFileManager (Recursive).h
//
// Copyright (c) 2007 3James Software. All rights reserved.
//
// This file is in the public domain.
//

#import <Cocoa/Cocoa.h>

@interface NSFileManager (Recursive)

- (BOOL) createDirectoryAtPath: (NSString *) path attributes: (NSDictionary *) attributes recursive: (BOOL) recursive;
- (BOOL) createDirectoryRecursivelyAtPath: (NSString *) path attributes: (NSDictionary *) attributes;

@end

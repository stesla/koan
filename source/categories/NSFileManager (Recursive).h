//
// NSFileManager (Recursive).h
//
// Copyright (c) 2004, 2005 3James Software
//
// This file is in the public domain.
//

#import <Cocoa/Cocoa.h>

@interface NSFileManager (Recursive)

- (BOOL) createDirectoryAtPath:(NSString *)path attributes:(NSDictionary *)attributes recursive:(BOOL)recursive;
- (BOOL) createDirectoryRecursivelyAtPath:(NSString *)path attributes:(NSDictionary *)attributes;

@end

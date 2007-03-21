//
// NSFileManager (Recursive).m
//
// Copyright (c) 2004, 2005 3James Software
//
// This file is in the public domain.
//

#import "NSFileManager (Recursive).h"

@implementation NSFileManager (Recursive)

- (BOOL) createDirectoryAtPath: (NSString *)path attributes: (NSDictionary *)attributes recursive: (BOOL)recursive
{
  if (recursive)
    return [self createDirectoryRecursivelyAtPath: path attributes: attributes];
  else
    return [self createDirectoryAtPath: path attributes: attributes];
}

- (BOOL) createDirectoryRecursivelyAtPath: (NSString *)path attributes: (NSDictionary *)attributes
{
  BOOL isDirectory;
  
  if (![self fileExistsAtPath: path isDirectory: &isDirectory])
  {
    if ([self fileExistsAtPath: [path stringByDeletingLastPathComponent] isDirectory: &isDirectory])
    {
      if (isDirectory)
        return [self createDirectoryAtPath: path attributes: attributes];
      else
        return NO;
    }
    else
    {
      if ([self createDirectoryRecursivelyAtPath: [path stringByDeletingLastPathComponent] attributes: attributes])
        return [self createDirectoryAtPath: path attributes: attributes];
      else
        return NO;
    }
  }
  else return isDirectory;
}

@end

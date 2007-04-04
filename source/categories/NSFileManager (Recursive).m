//
// NSFileManager (Recursive).m
//
// Copyright (c) 2007 3James Software.
//
// License:
// 
//   Permission is hereby granted, free of charge, to any person obtaining a
//   copy of this software and associated documentation files (the "Software"),
//   to deal in the Software without restriction, including without limitation
//   the rights to use, copy, modify, merge, publish, distribute, sublicense,
//   and/or sell copies of the Software, and to permit persons to whom the
//   Software is furnished to do so, subject to the following conditions:
//
//   The above copyright notice and this permission notice shall be included in
//   all copies or substantial portions of the Software.
//
//   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//   FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//   DEALINGS IN THE SOFTWARE.
//

#import "NSFileManager (Recursive).h"

@implementation NSFileManager (Recursive)

- (BOOL) createDirectoryAtPath: (NSString *) path attributes: (NSDictionary *) attributes recursive: (BOOL) recursive
{
  if (recursive)
    return [self createDirectoryRecursivelyAtPath: path attributes: attributes];
  else
    return [self createDirectoryAtPath: path attributes: attributes];
}

- (BOOL) createDirectoryRecursivelyAtPath: (NSString *) path attributes: (NSDictionary *) attributes
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

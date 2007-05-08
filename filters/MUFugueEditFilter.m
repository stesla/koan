//
// MUFugueEditFilter.m
//
// Copyright (c) 2007 3James Software.
//

#import "MUFugueEditFilter.h"

@implementation MUFugueEditFilter

- (NSAttributedString *) filter: (NSAttributedString *) string
{
  NSString *plainString = [string string];
  NSString *fugueEditPrefix = @"FugueEdit > ";
  
  if ([plainString hasPrefix: fugueEditPrefix])
  {
    NSString *editString = [plainString substringFromIndex: [fugueEditPrefix length]];
    return [NSAttributedString attributedStringWithString: @""];
  }
  else
    return string;
}

@end

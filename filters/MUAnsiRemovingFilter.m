//
//  MUAnsiRemovingFilter.m
//  Koan
//
//  Created by Samuel on 11/14/04.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import "MUAnsiRemovingFilter.h"

@interface MUAnsiRemovingFilter (Private)
- (BOOL) extractCode:(NSMutableString *)editString;
- (int) scanUpToCodeInString:(NSString *)string;
- (int) scanThruEndOfCodeAt:(int)index inString:(NSString *)string;
@end

@implementation MUAnsiRemovingFilter

+ (MUInputFilter *) filter
{
  return [[[MUAnsiRemovingFilter alloc] init] autorelease];
}

- (void) filter:(NSString *)string
{
  NSMutableString *editString = [NSMutableString stringWithString:string];
  while ([self extractCode:editString])
    ;
  [[self successor] filter:editString];
}

@end

@implementation MUAnsiRemovingFilter (Private)

- (BOOL) extractCode:(NSMutableString *)editString
{
  NSRange codeRange;
  
  codeRange.location = [self scanUpToCodeInString:editString];
  codeRange.length = [self scanThruEndOfCodeAt:codeRange.location
                                      inString:editString];
  
  if (codeRange.location < [editString length])
  {
    [editString deleteCharactersInRange:codeRange];
    return YES;
  }
  else
    return NO;
}

- (int) scanUpToCodeInString:(NSString *)string
{
  NSCharacterSet *stopSet = 
    [NSCharacterSet characterSetWithCharactersInString:@"\033"];
  NSScanner *scanner = [NSScanner scannerWithString:string];
  NSString *output = @"";
  [scanner scanUpToCharactersFromSet:stopSet intoString:&output];
  return [output length];
}

- (int) scanThruEndOfCodeAt:(int)index inString:(NSString *)string
{
  NSScanner *scanner = [NSScanner scannerWithString:
    [string substringFromIndex:index]];
  NSCharacterSet *resumeSet = 
    [NSCharacterSet characterSetWithCharactersInString:
      @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"];
  NSString *ansiCode = @"";
  [scanner scanUpToCharactersFromSet:resumeSet intoString:&ansiCode]; 
  return [ansiCode length] + 1;
}

@end

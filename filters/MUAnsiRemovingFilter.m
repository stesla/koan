//
//  MUAnsiRemovingFilter.m
//  Koan
//
//  Created by Samuel on 11/14/04.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import "MUAnsiRemovingFilter.h"

@interface MUAnsiRemovingFilter (Private)
- (void) extractCode:(NSMutableString *)editString;
@end

@implementation MUAnsiRemovingFilter

+ (MUInputFilter *) filter
{
  return [[[MUAnsiRemovingFilter alloc] init] autorelease];
}

- (void) filter:(NSString *)string
{
  NSMutableString *editString = [NSMutableString stringWithString:string];
  [self extractCode:editString];
  [[self successor] filter:editString];
}

@end

@implementation MUAnsiRemovingFilter (Private)

- (void) extractCode:(NSMutableString *)editString
{
  NSCharacterSet *stopSet = 
    [NSCharacterSet characterSetWithCharactersInString:@"\033"];
  
  NSCharacterSet *resumeSet = 
    [NSCharacterSet characterSetWithCharactersInString:
      @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"];
  
  NSScanner *scanner = [NSScanner scannerWithString:editString];
  NSString *output = @"";
  NSString *ansiCode = @"";
  NSRange codeRange;
  
  [scanner scanUpToCharactersFromSet:stopSet intoString:&output];
  codeRange.location = [output length];
  [scanner scanUpToCharactersFromSet:resumeSet intoString:&ansiCode]; 
  codeRange.length = [ansiCode length] + 1;
  
  if (codeRange.location < [editString length])
    [editString deleteCharactersInRange:codeRange];  
}

@end

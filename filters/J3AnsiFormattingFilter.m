//
// J3AnsiFormattingFilter.m
//
// Copyright (c) 2004, 2005 3James Software
//

#import "J3AnsiFormattingFilter.h"

@interface J3AnsiFormattingFilter (Private)
- (BOOL) extractCode:(NSMutableAttributedString *)editString;
- (int) scanUpToCodeInString:(NSString *)string;
- (int) scanThruEndOfCodeAt:(int)index inString:(NSString *)string;
@end

@implementation J3AnsiFormattingFilter

- (NSAttributedString *) filter:(NSAttributedString *)string
{
  NSMutableAttributedString *editString = [[NSMutableAttributedString alloc] initWithAttributedString:string];
  
  while ([self extractCode:editString])
    ;
  
  [editString autorelease];
  return editString;
}

@end

@implementation J3AnsiFormattingFilter (Private)

- (BOOL) extractCode:(NSMutableAttributedString *)editString
{
  NSRange codeRange;
  
  codeRange.location = [self scanUpToCodeInString:[editString string]];
  
  if (codeRange.location != NSNotFound)
  {
    codeRange.length = [self scanThruEndOfCodeAt:codeRange.location
                                        inString:[editString string]];
    
    if (codeRange.location < [editString length])
    {
      [editString deleteCharactersInRange:codeRange];
      return YES;
    }
  }

  return NO;
}

- (int) scanUpToCodeInString:(NSString *)string
{
  NSCharacterSet *stopSet = 
    [NSCharacterSet characterSetWithCharactersInString:@"\x1B"];
  NSRange stopRange = [string rangeOfCharacterFromSet:stopSet];
  NSScanner *scanner = [NSScanner scannerWithString:string];
  [scanner setCharactersToBeSkipped:
    [NSCharacterSet characterSetWithCharactersInString:@""]];

  if (stopRange.location == NSNotFound)
    return NSNotFound;
  
  while ([scanner scanUpToCharactersFromSet:stopSet intoString:nil])
    ;
  return [scanner scanLocation];
}

- (int) scanThruEndOfCodeAt:(int)index inString:(NSString *)string
{
  NSScanner *scanner = [NSScanner scannerWithString:string];
  [scanner setScanLocation:index];
  [scanner setCharactersToBeSkipped:
    [NSCharacterSet characterSetWithCharactersInString:@""]];

  NSCharacterSet *resumeSet = 
    [NSCharacterSet characterSetWithCharactersInString:
      @"m"];

  //TODO: Figure out how to do this with a nil intoString: parameter
  //like I do above with scanUpToCodeInString:
  NSString *ansiCode = @"";
  [scanner scanUpToCharactersFromSet:resumeSet intoString:&ansiCode];
  return [ansiCode length] + 1;
}

@end

//
// MUAnsiRemovingFilter.m
//
// Copyright (C) 2004 Tyler Berry and Samuel Tesla
//
// Koan is free software; you can redistribute it and/or modify it under the
// terms of the GNU General Public License as published by the Free Software
// Foundation; either version 2 of the License, or (at your option) any later
// version.
//
// Koan is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// Koan; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
// Suite 330, Boston, MA 02111-1307 USA
//

#import "MUAnsiRemovingFilter.h"

@interface MUAnsiRemovingFilter (Private)
- (BOOL) extractCode:(NSMutableAttributedString *)editString;
- (int) scanUpToCodeInString:(NSString *)string;
- (int) scanThruEndOfCodeAt:(int)index inString:(NSString *)string;
@end

@implementation MUAnsiRemovingFilter

+ (MUFilter *) filter
{
  return [[[MUAnsiRemovingFilter alloc] init] autorelease];
}

- (NSAttributedString *) filter:(NSAttributedString *)string
{
  NSMutableAttributedString *editString = [[NSMutableAttributedString alloc] initWithAttributedString:string];
  
  while ([self extractCode:editString])
    ;
  
  [editString autorelease];
  return editString;
}

@end

@implementation MUAnsiRemovingFilter (Private)

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
      @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"];

  //TODO: Figure out how to do this with a nil intoString: parameter
  //like I do above with scanUpToCodeInString:
  NSString *ansiCode = @"";
  [scanner scanUpToCharactersFromSet:resumeSet intoString:&ansiCode];
  return [ansiCode length] + 1;
}

@end

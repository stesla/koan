//
//  J3NaiveANSIFilter.m
//  Koan
//
//  Created by Samuel on 1/25/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "J3NaiveANSIFilter.h"

@interface J3NaiveANSIFilter (Private)
- (BOOL) extractCode:(NSMutableAttributedString *)editString;
- (int) getNumber:(int *)num atIndex:(int)index inString:(NSString *)string;
- (int) scanUpToCodeInString:(NSString *)string;
- (int) scanThruEndOfCodeAt:(int)index inString:(NSString *)string;
- (void) setForegroundColor:(NSColor *)color inDictionary:(NSMutableDictionary *)dict;
- (void) setBackColor:(NSColor *)color inDictionary:(NSMutableDictionary *)dict;
- (void) setAttributeInString:(NSMutableAttributedString *)editString
                      atIndex:(int)index
                      forCode:(J3ANSICode)code;
@end

@implementation J3NaiveANSIFilter

- (NSAttributedString *) filter:(NSAttributedString *)string
{
  NSMutableAttributedString *editString = [[NSMutableAttributedString alloc] initWithAttributedString:string];
  
  while ([self extractCode:editString])
    ;
  
  [editString autorelease];
  return editString;
}

@end

@implementation J3NaiveANSIFilter (Private)
- (BOOL) extractCode:(NSMutableAttributedString *)editString
{
  NSRange codeRange;
  
  codeRange.location = [self scanUpToCodeInString:[editString string]];
  
  if (codeRange.location != NSNotFound)
  {
    // codeRange.location is the position of ESC
    NSString *ansiCode;
    codeRange.length = [self scanThruEndOfCodeAt:codeRange.location
                                        inString:[editString string]];

    ansiCode = [[editString string] substringWithRange:codeRange];
    if ([ansiCode characterAtIndex:1] == '[')
    {
      int code;
      ansiCode = [ansiCode substringFromIndex:2];
      
      [self getNumber:&code
              atIndex:0
             inString:ansiCode];
      
      [self setAttributeInString:editString
                         atIndex:codeRange.location
                         forCode:code];
    }
    
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

- (int) getNumber:(int *)num atIndex:(int)index inString:(NSString *)string
{
  NSScanner *scanner = [NSScanner scannerWithString:string];
  [scanner scanInt:num];
  return [scanner scanLocation];
}

- (void) setForegroundColor:(NSColor *)color inDictionary:(NSMutableDictionary *)dict
{
  [dict setValue:color forKey:J3ANSIForegroundColorAttributeName];
}

- (void) setBackColor:(NSColor *)color inDictionary:(NSMutableDictionary *)dict
{
  [dict setValue:color forKey:J3ANSIBackgroundColorAttributeName];
}

/*
- (NSColor *) getForegroundAtIndex:(int)i
{
    
}
*/

- (void) setAttributeInString:(NSMutableAttributedString *)editString
                      atIndex:(int)index
                      forCode:(J3ANSICode)code
{
  NSMutableDictionary *attrs = 
    [[[editString attributesAtIndex:index
                     effectiveRange:NULL] mutableCopy] autorelease];
  NSRange range;
  range.location = index;
  range.length = [editString length] - index;
  
  switch (code)
  {
    case J3ANSIForegroundBlack:
      [self setForegroundColor:[NSColor blackColor] inDictionary:attrs];
      break;

    case J3ANSIForegroundRed:
      [self setForegroundColor:[NSColor redColor] inDictionary:attrs];
      break;

    case J3ANSIForegroundGreen:
      [self setForegroundColor:[NSColor greenColor] inDictionary:attrs];
      break;
      
    case J3ANSIForegroundYellow:
      [self setForegroundColor:[NSColor yellowColor] inDictionary:attrs];
      break;
      
    case J3ANSIForegroundBlue:
      [self setForegroundColor:[NSColor blueColor] inDictionary:attrs];
      break;
      
    case J3ANSIForegroundMagenta:
      [self setForegroundColor:[NSColor magentaColor] inDictionary:attrs];
      break;
      
    case J3ANSIForegroundCyan:
      [self setForegroundColor:[NSColor cyanColor] inDictionary:attrs];
      break;
      
    case J3ANSIForegroundWhite:
      [self setForegroundColor:[NSColor whiteColor] inDictionary:attrs];
      break;
      
    case J3ANSIBackBlack:
      [self setBackColor:[NSColor blackColor] inDictionary:attrs];
      break;
      
    case J3ANSIBackRed:
      [self setBackColor:[NSColor redColor] inDictionary:attrs];
      break;
      
    case J3ANSIBackGreen:
      [self setBackColor:[NSColor greenColor] inDictionary:attrs];
      break;
      
    case J3ANSIBackYellow:
      [self setBackColor:[NSColor yellowColor] inDictionary:attrs];
      break;
      
    case J3ANSIBackBlue:
      [self setBackColor:[NSColor blueColor] inDictionary:attrs];
      break;
      
    case J3ANSIBackMagenta:
      [self setBackColor:[NSColor magentaColor] inDictionary:attrs];
      break;
      
    case J3ANSIBackCyan:
      [self setBackColor:[NSColor cyanColor] inDictionary:attrs];
      break;
      
    case J3ANSIBackWhite:
      [self setBackColor:[NSColor whiteColor] inDictionary:attrs];
      break;

    default:
      break;
  }
  
  [editString setAttributes:attrs range:range];
}

@end

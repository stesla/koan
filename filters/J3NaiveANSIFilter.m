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
- (void) setForeColor:(NSColor *)color inDictionary:(NSMutableDictionary *)dict;
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

- (void) setForeColor:(NSColor *)color inDictionary:(NSMutableDictionary *)dict
{
  [dict setValue:color forKey:J3ANSIForeColorAttributeName];
}

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
    case J3ANSIForeBlack:
      [self setForeColor:[NSColor blackColor] inDictionary:attrs];
      break;

    case J3ANSIForeRed:
      [self setForeColor:[NSColor redColor] inDictionary:attrs];
      break;

    case J3ANSIForeGreen:
      [self setForeColor:[NSColor greenColor] inDictionary:attrs];
      break;
      
    case J3ANSIForeYellow:
      [self setForeColor:[NSColor yellowColor] inDictionary:attrs];
      break;
      
    case J3ANSIForeBlue:
      [self setForeColor:[NSColor blueColor] inDictionary:attrs];
      break;
      
    case J3ANSIForeMagenta:
      [self setForeColor:[NSColor magentaColor] inDictionary:attrs];
      break;
      
    case J3ANSIForeCyan:
      [self setForeColor:[NSColor cyanColor] inDictionary:attrs];
      break;
      
    case J3ANSIForeWhite:
      [self setForeColor:[NSColor whiteColor] inDictionary:attrs];
      break;

    default:
      break;
  }
  
  [editString setAttributes:attrs range:range];
}

@end

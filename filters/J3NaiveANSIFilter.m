//
//  J3NaiveANSIFilter.m
//  Koan
//
//  Created by Samuel on 1/25/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "J3NaiveANSIFilter.h"

typedef enum _J3NaiveANSICode
{
  J3NaiveANSIReset = 0,
  J3NaiveANSIBoldOn = 1,
  J3NaiveANSIItalicsOn = 3,
  J3NaiveANSIUnderlineOn = 4,
  J3NaiveANSIInverseOn = 7,
  J3NaiveANSIStrikeOn = 9,
  J3NaiveANSIBoldOff = 22,
  J3NaiveANSIItalicsOff = 23,
  J3NaiveANSIUnderlineOff = 24,
  J3NaiveANSIInverseOff = 27,
  J3NaiveANSIStrikeOff = 29,
  J3NaiveANSIForeBlack = 30,
  J3NaiveANSIForeRed = 31,
  J3NaiveANSIForeGreen = 32,
  J3NaiveANSIForeYellow = 33,
  J3NaiveANSIForeBlue = 34,
  J3NaiveANSIForeMagenta = 35,
  J3NaiveANSIForeCyan = 36,
  J3NaiveANSIForeWhite = 37,
  J3NaiveANSIForeDefault = 39,
  J4NaiveANSIBackBlack = 40,
  J4NaiveANSIBackRed = 41,
  J4NaiveANSIBackGreen = 42,
  J4NaiveANSIBackYellow = 43,
  J4NaiveANSIBackBlue = 44,
  J4NaiveANSIBackMagenta = 45,
  J4NaiveANSIBackCyan = 46,
  J4NaiveANSIBackWhite = 47,
  J4NaiveANSIBackDefault = 49
} J3NaiveANSICode;

@interface J3NaiveANSIFilter (Private)
- (BOOL) extractCode:(NSMutableAttributedString *)editString;
- (int) getNumber:(int *)num atIndex:(int)index inString:(NSString *)string;
- (int) scanUpToCodeInString:(NSString *)string;
- (int) scanThruEndOfCodeAt:(int)index inString:(NSString *)string;
- (void) setForeColor:(NSColor *)color inDictionary:(NSMutableDictionary *)dict;
- (void) setAttributeInString:(NSMutableAttributedString *)editString
                      atIndex:(int)index
                      forCode:(J3NaiveANSICode)code;
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
                      forCode:(J3NaiveANSICode)code
{
  NSMutableDictionary *attrs = 
    [[[editString attributesAtIndex:index
                     effectiveRange:NULL] mutableCopy] autorelease];
  NSRange range;
  range.location = index;
  range.length = [editString length] - index;
  
  switch (code)
  {
    case J3NaiveANSIForeBlack:
      [self setForeColor:[NSColor blackColor] inDictionary:attrs];
      break;
      
    case J3NaiveANSIForeRed:
      [self setForeColor:[NSColor redColor] inDictionary:attrs];
      break;
    
    case J3NaiveANSIForeGreen:
      [self setForeColor:[NSColor greenColor] inDictionary:attrs];
      break;
      
    case J3NaiveANSIForeYellow:
      [self setForeColor:[NSColor yellowColor] inDictionary:attrs];
      break;
      
    case J3NaiveANSIForeBlue:
      [self setForeColor:[NSColor blueColor] inDictionary:attrs];
      break;
      
    case J3NaiveANSIForeMagenta:
      [self setForeColor:[NSColor magentaColor] inDictionary:attrs];
      break;
      
    case J3NaiveANSIForeCyan:
      [self setForeColor:[NSColor cyanColor] inDictionary:attrs];
      break;
      
    case J3NaiveANSIForeWhite:
      [self setForeColor:[NSColor cyanColor] inDictionary:attrs];
      break;
      
    default:
      break;
  }
  
  [editString setAttributes:attrs range:range];
}

@end

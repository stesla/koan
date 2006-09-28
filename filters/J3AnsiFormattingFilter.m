//
// J3AnsiFormattingFilter.m
//
// Copyright (c) 2004, 2005 3James Software
//

#import "J3AnsiFormattingFilter.h"
#import "MUFormatting.h"

@interface J3AnsiFormattingFilter (Private)

- (NSString *) attributeNameForAnsiCode;
- (id) attributeValueForAnsiCode;
- (BOOL) extractCode:(NSMutableAttributedString *)editString;
- (void) resetAllAttributesInString:(NSMutableAttributedString *)string inRange:(NSRange)range;
- (int) scanUpToCodeInString:(NSString *)string;
- (int) scanThruEndOfCodeAt:(int)index inString:(NSString *)string;
- (void) setAttributesInString:(NSMutableAttributedString *)string atPosition:(int)start;

@end

@implementation J3AnsiFormattingFilter

- (NSAttributedString *) filter:(NSAttributedString *)string;
{
  NSMutableAttributedString *editString = [[NSMutableAttributedString alloc] initWithAttributedString:string];
  
  while ([self extractCode:editString])
    ;
  
  [editString autorelease];
  return editString;
}

- (id) init;
{
  if (!(self = [super init]))
    return nil;
  [self at:&formatting put:[MUFormatting formattingForTesting]];
  return self;
}

@end

@implementation J3AnsiFormattingFilter (Private)

- (NSString *) attributeNameForAnsiCode;
{
  switch ([[ansiCode substringFromIndex:2] intValue]) 
  {
    case J3AnsiBackgroundBlack:
    case J3AnsiBackgroundBlue:
    case J3AnsiBackgroundCyan:
    case J3AnsiBackgroundDefault:
    case J3AnsiBackgroundGreen:
    case J3AnsiBackgroundMagenta:
    case J3AnsiBackgroundRed:
    case J3AnsiBackgroundWhite:
    case J3AnsiBackgroundYellow:
      return NSBackgroundColorAttributeName;
      break;
    case J3AnsiForegroundBlack:
    case J3AnsiForegroundBlue:
    case J3AnsiForegroundCyan:
    case J3AnsiForegroundDefault:
    case J3AnsiForegroundGreen:
    case J3AnsiForegroundMagenta:
    case J3AnsiForegroundRed:
    case J3AnsiForegroundWhite:
    case J3AnsiForegroundYellow:
      return NSForegroundColorAttributeName;
      break;
  }
return nil;
}

- (id) attributeValueForAnsiCode;
{
  switch ([[ansiCode substringFromIndex:2] intValue]) 
  {
    case J3AnsiBackgroundBlack: 
    case J3AnsiForegroundBlack: 
      return [NSColor blackColor];
      break;
      
    case J3AnsiBackgroundBlue:
    case J3AnsiForegroundBlue:
      return [NSColor blueColor];
      break;

    case J3AnsiBackgroundCyan:
    case J3AnsiForegroundCyan:
      return [NSColor cyanColor];
      break;
      
    case J3AnsiBackgroundDefault:
      return [formatting background];
      break;

    case J3AnsiForegroundDefault:
      return [formatting foreground];
      break;
      
    case J3AnsiBackgroundGreen:
    case J3AnsiForegroundGreen:
      return [NSColor greenColor];
      break;
      
    case J3AnsiBackgroundMagenta:
    case J3AnsiForegroundMagenta:
      return [NSColor magentaColor];
      break;
      
    case J3AnsiBackgroundRed:
    case J3AnsiForegroundRed:
      return [NSColor redColor];
      break;
      
    case J3AnsiBackgroundWhite:
    case J3AnsiForegroundWhite:
      return [NSColor whiteColor];
      break;
      
    case J3AnsiBackgroundYellow:
    case J3AnsiForegroundYellow:
      return [NSColor yellowColor];
      break;    
  }
  return nil;
}

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
      [self setAttributesInString:editString atPosition:codeRange.location];
      return YES;
    }
  }

  return NO;
}

- (void) resetAllAttributesInString:(NSMutableAttributedString *)string inRange:(NSRange)range;
{
  [string addAttribute:NSForegroundColorAttributeName value:[formatting foreground] range:range];
  [string addAttribute:NSBackgroundColorAttributeName value:[formatting background] range:range];
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
  ansiCode = @"";
  [scanner scanUpToCharactersFromSet:resumeSet intoString:&ansiCode];
  return [ansiCode length] + 1;
}

- (void) setAttributesInString:(NSMutableAttributedString *)string atPosition:(int)start;
{
  NSRange formattingRange;
  NSString * attributeName = nil;
  id attributeValue = nil;

  formattingRange.location = start;
  formattingRange.length = [string length] - start;

  if ([[ansiCode substringFromIndex:2] intValue] == 0)
    [self resetAllAttributesInString:string inRange:formattingRange];
  
  attributeName = [self attributeNameForAnsiCode];
  if (!attributeName)
    return;

  
  attributeValue = [self attributeValueForAnsiCode];
  if (attributeValue)
    [string addAttribute:attributeName value:attributeValue range:formattingRange];    
  else if ([attributeName isEqualToString:NSForegroundColorAttributeName])
    [string addAttribute:NSForegroundColorAttributeName value:[formatting foreground] range:formattingRange];
  else if ([attributeName isEqualToString:NSBackgroundColorAttributeName])
    [string addAttribute:NSBackgroundColorAttributeName value:[formatting background] range:formattingRange];
  else
    [string removeAttribute:attributeName range:formattingRange];
}

@end

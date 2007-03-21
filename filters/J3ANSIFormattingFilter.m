//
// J3ANSIFormattingFilter.m
//
// Copyright (c) 2004, 2005, 2006 3James Software
//

#import "J3ANSIFormattingFilter.h"
#import "J3Formatting.h"
#import "NSFont (Traits).h"

@interface J3ANSIFormattingFilter (Private)

- (NSString *) attributeNameForAnsiCode;
- (id) attributeValueForAnsiCodeAndString: (NSAttributedString *)string location: (int)location;
- (BOOL) extractCode: (NSMutableAttributedString *)editString;
- (NSFont *) fontInString: (NSAttributedString *)string atLocation: (int)location;
- (NSFont *) makeFontBold: (NSFont *)font;
- (NSFont *) makeFontUnbold: (NSFont *)font;
- (void) resetAllAttributesInString: (NSMutableAttributedString *)string fromLocation: (int)location;
- (void) resetBackgroundInString: (NSMutableAttributedString *)string fromLocation: (int)location;
- (void) resetFontInString: (NSMutableAttributedString *)string fromLocation: (int)location;
- (void) resetForegroundInString: (NSMutableAttributedString *)string fromLocation: (int)location;
- (void) resetUnderlineInString: (NSMutableAttributedString *)string fromLocation: (int)location;
- (void) setAttribute: (NSString *)attribute toValue: (id)value inString: (NSMutableAttributedString *)string fromLocation: (int)location;
- (void) setAttributes: (NSDictionary *)attributes onString: (NSMutableAttributedString *)string fromLocation: (int)location;
- (int) scanUpToCodeInString: (NSString *)string;
- (int) scanThruEndOfCodeAt: (int)index inString: (NSString *)string;
- (void) setAttributesInString: (NSMutableAttributedString *)string atPosition: (int)start;
- (NSFont *) setTrait: (NSFontTraitMask)trait onFont: (NSFont *)font;

@end

@implementation J3ANSIFormattingFilter
+ (J3Filter *) filterWithFormatting: (NSObject <J3Formatting> *)format;
{
  return [[[self alloc] initWithFormatting: format] autorelease];
}


- (NSAttributedString *) filter: (NSAttributedString *)string;
{
  NSMutableAttributedString *editString = [[NSMutableAttributedString alloc] initWithAttributedString: string];
  
  [self setAttributes: currentAttributes onString: editString fromLocation: 0];
  
  while ([self extractCode: editString])
    ;
  
  [editString autorelease];
  return editString;
}

- (id) initWithFormatting: (NSObject <J3Formatting> *)format;
{
  if (!(self = [super init]))
    return nil;
  if (!format)
    return nil;
  [self at: &formatting put: format];
  [self at: &currentAttributes put: [NSMutableDictionary dictionary]];
  [currentAttributes setValue: [formatting font] forKey: NSFontAttributeName];
  return self; 
}

- (id) init;
{
  return [self initWithFormatting: [J3Formatting formattingForTesting]];
}

@end

@implementation J3ANSIFormattingFilter (Private)

- (NSString *) attributeNameForAnsiCode;
{
  switch ([[ansiCode substringFromIndex: 2] intValue]) 
  {
    case J3ANSIBackgroundBlack:
    case J3ANSIBackgroundBlue:
    case J3ANSIBackgroundCyan:
    case J3ANSIBackgroundDefault:
    case J3ANSIBackgroundGreen:
    case J3ANSIBackgroundMagenta:
    case J3ANSIBackgroundRed:
    case J3ANSIBackgroundWhite:
    case J3ANSIBackgroundYellow:
      return NSBackgroundColorAttributeName;
      break;
      
    case J3ANSIForegroundBlack:
    case J3ANSIForegroundBlue:
    case J3ANSIForegroundCyan:
    case J3ANSIForegroundDefault:
    case J3ANSIForegroundGreen:
    case J3ANSIForegroundMagenta:
    case J3ANSIForegroundRed:
    case J3ANSIForegroundWhite:
    case J3ANSIForegroundYellow:
      return NSForegroundColorAttributeName;
      break;
      
    case J3ANSIBoldOn:
    case J3ANSIBoldOff:
      return NSFontAttributeName;
      break;
      
    case J3ANSIUnderlineOn:
    case J3ANSIUnderlineOff:
      return NSUnderlineStyleAttributeName;
      break;
  }
  return nil;
}

- (id) attributeValueForAnsiCodeAndString: (NSAttributedString *)string location: (int)location;
{
  switch ([[ansiCode substringFromIndex: 2] intValue]) 
  {
    case J3ANSIBackgroundBlack:  
    case J3ANSIForegroundBlack:  
      return [NSColor darkGrayColor];
      break;
      
    case J3ANSIBackgroundBlue:
    case J3ANSIForegroundBlue:
      return [NSColor blueColor];
      break;

    case J3ANSIBackgroundCyan:
    case J3ANSIForegroundCyan:
      return [NSColor cyanColor];
      break;
      
    case J3ANSIBackgroundDefault:
      return [formatting background];
      break;

    case J3ANSIForegroundDefault:
      return [formatting foreground];
      break;
      
    case J3ANSIBackgroundGreen:
    case J3ANSIForegroundGreen:
      return [NSColor greenColor];
      break;
      
    case J3ANSIBackgroundMagenta:
    case J3ANSIForegroundMagenta:
      return [NSColor magentaColor];
      break;
      
    case J3ANSIBackgroundRed:
    case J3ANSIForegroundRed:
      return [NSColor redColor];
      break;
      
    case J3ANSIBackgroundWhite:
    case J3ANSIForegroundWhite:
      return [NSColor whiteColor];
      break;
      
    case J3ANSIBackgroundYellow:
    case J3ANSIForegroundYellow:
      return [NSColor yellowColor];
      break;    
      
    case J3ANSIBoldOn:
      return [self makeFontBold: [self fontInString: string atLocation: location]];
      break;
        
    case J3ANSIBoldOff:
      return [self makeFontUnbold: [self fontInString: string atLocation: location]];
      break;
      
    case J3ANSIUnderlineOn:
      return [NSNumber numberWithInt: NSSingleUnderlineStyle];
      break;
      
    case J3ANSIUnderlineOff:
      return [NSNumber numberWithInt: NSNoUnderlineStyle];
      break;
  }
  return nil;
}

- (BOOL) extractCode: (NSMutableAttributedString *)editString
{
  NSRange codeRange;
  
  codeRange.location = [self scanUpToCodeInString: [editString string]];
  
  if (codeRange.location != NSNotFound)
  {
    codeRange.length = [self scanThruEndOfCodeAt: codeRange.location
                                        inString: [editString string]];
    
    if (codeRange.location < [editString length])
    {
      [editString deleteCharactersInRange: codeRange];
      [self setAttributesInString: editString atPosition: codeRange.location];
      return YES;
    }
  }

  return NO;
}

- (NSFont *) fontInString: (NSAttributedString *)string atLocation: (int)location;
{
  return [string attribute: NSFontAttributeName atIndex: location effectiveRange: NULL];
}

- (NSFont *) makeFontBold: (NSFont *)font;
{  
  if ([[formatting font] isBold])
    return [font fontWithTrait: NSUnboldFontMask];
  else
    return [font fontWithTrait: NSBoldFontMask];
}

- (NSFont *) makeFontUnbold: (NSFont *)font;
{
  if ([[formatting font] isBold])
    return [font fontWithTrait: NSBoldFontMask];
  else
    return [font fontWithTrait: NSUnboldFontMask];
}

- (void) resetAllAttributesInString: (NSMutableAttributedString *)string fromLocation: (int)location;
{
  [self resetBackgroundInString: string fromLocation: location];
  [self resetForegroundInString: string fromLocation: location];
  [self resetFontInString: string fromLocation: location];
  [self resetUnderlineInString: string fromLocation: location];
}

- (void) resetBackgroundInString: (NSMutableAttributedString *)string fromLocation: (int)location;
{
  [self setAttribute: NSBackgroundColorAttributeName toValue: [formatting background] inString: string fromLocation: location];
}

- (void) resetFontInString: (NSMutableAttributedString *)string fromLocation: (int)location;
{
  [self setAttribute: NSFontAttributeName toValue: [formatting font] inString: string fromLocation: location];
}

- (void) resetForegroundInString: (NSMutableAttributedString *)string fromLocation: (int)location;
{
  [self setAttribute: NSForegroundColorAttributeName toValue: [formatting foreground] inString: string fromLocation: location];
}

- (void) resetUnderlineInString: (NSMutableAttributedString *)string fromLocation: (int)location;
{
  [self setAttribute: NSUnderlineStyleAttributeName toValue: [NSNumber numberWithInt: NSNoUnderlineStyle] inString: string fromLocation: location];
}

- (void) setAttribute: (NSString *)attribute toValue: (id)value inString: (NSMutableAttributedString *)string fromLocation: (int)location;
{
  [string addAttribute: attribute value: value range: NSMakeRange (location,[string length] - location)];
  [currentAttributes setObject: value forKey: attribute];
}

- (void) setAttributes: (NSDictionary *)attributes onString: (NSMutableAttributedString *)string fromLocation: (int)location;
{
  NSDictionary * attributeCopy = [attributes copy];
  NSEnumerator * keyEnumerator = [attributeCopy keyEnumerator];
  NSString * key;
  
  while ((key = [keyEnumerator nextObject]))
    [self setAttribute: key toValue: [attributeCopy valueForKey: key] inString: string fromLocation: location];
}

- (int) scanUpToCodeInString: (NSString *)string
{
  NSCharacterSet *stopSet = 
    [NSCharacterSet characterSetWithCharactersInString: @"\x1B"];
  NSRange stopRange = [string rangeOfCharacterFromSet: stopSet];
  NSScanner *scanner = [NSScanner scannerWithString: string];
  [scanner setCharactersToBeSkipped:
    [NSCharacterSet characterSetWithCharactersInString: @""]];

  if (stopRange.location == NSNotFound)
    return NSNotFound;
  
  while ([scanner scanUpToCharactersFromSet: stopSet intoString: nil])
    ;
  return [scanner scanLocation];
}

- (int) scanThruEndOfCodeAt: (int)index inString: (NSString *)string
{
  NSScanner *scanner = [NSScanner scannerWithString: string];
  [scanner setScanLocation: index];
  [scanner setCharactersToBeSkipped:
    [NSCharacterSet characterSetWithCharactersInString: @""]];

  NSCharacterSet *resumeSet = 
    [NSCharacterSet characterSetWithCharactersInString:
      @"m"];

  //TODO:  Figure out how to do this with a nil intoString:  parameter
  //like I do above with scanUpToCodeInString:
  ansiCode = @"";
  [scanner scanUpToCharactersFromSet: resumeSet intoString: &ansiCode];
  return [ansiCode length] + 1;
}

- (void) setAttributesInString: (NSMutableAttributedString *)string atPosition: (int)start;
{
  NSString * attributeName = nil;
  id attributeValue = nil;

  if ([string length] <= start)
    return;
  
  if ([[ansiCode substringFromIndex: 2] intValue] == 0)
    [self resetAllAttributesInString: string fromLocation: start];
  
  attributeName = [self attributeNameForAnsiCode];
  if (!attributeName)
    return;

  attributeValue = [self attributeValueForAnsiCodeAndString: string location: start];
  if (attributeValue)
    [self setAttribute: attributeName toValue: attributeValue inString: string fromLocation: start];
  else if ([attributeName isEqualToString: NSForegroundColorAttributeName])
    [self resetForegroundInString: string fromLocation: start];
  else if ([attributeName isEqualToString: NSBackgroundColorAttributeName])
    [self resetBackgroundInString: string fromLocation: start];
  else
    @throw [NSException exceptionWithName: @"J3ANSIException" reason: @"Did not provide attributeValue" userInfo: nil];
}

- (NSFont *) setTrait: (NSFontTraitMask)trait onFont: (NSFont *)font;
{
  NSFontManager * fontManager = [NSFontManager sharedFontManager];
  return [fontManager convertFont: font toHaveTrait: trait];
}

@end

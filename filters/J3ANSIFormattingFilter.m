//
// J3ANSIFormattingFilter.m
//
// Copyright (c) 2010 3James Software.
//

#import "J3ANSIFormattingFilter.h"
#import "J3Formatter.h"
#import "NSFont (Traits).h"

@interface J3ANSIFormattingFilter (Private)

- (NSString *) attributeNameForANSICode;
- (id) attributeValueForANSICodeInString: (NSAttributedString *) string atLocation: (unsigned) startLocation;
- (BOOL) extractCode: (NSMutableAttributedString *) editString;
- (NSFont *) fontInString: (NSAttributedString *) string atLocation: (unsigned) location;
- (NSFont *) makeFontBold: (NSFont *) font;
- (NSFont *) makeFontUnbold: (NSFont *) font;
- (void) resetAllAttributesInString: (NSMutableAttributedString *) string fromLocation: (unsigned) startLocation;
- (void) resetBackgroundInString: (NSMutableAttributedString *) string fromLocation: (unsigned) startLocation;
- (void) resetFontInString: (NSMutableAttributedString *) string fromLocation: (unsigned) startLocation;
- (void) resetForegroundInString: (NSMutableAttributedString *) string fromLocation: (unsigned) startLocation;
- (void) resetUnderlineInString: (NSMutableAttributedString *) string fromLocation: (unsigned) startLocation;
- (void) setAttribute: (NSString *) attribute toValue: (id) value inString: (NSMutableAttributedString *) string fromLocation: (unsigned) startLocation;
- (void) setAttributes: (NSDictionary *) attributes onString: (NSMutableAttributedString *) string fromLocation: (unsigned) startLocation;
- (int) scanUpToCodeInString: (NSString *) string;
- (int) scanThruEndOfCodeAt: (unsigned) index inString: (NSString *) string;
- (void) setAttributesInString: (NSMutableAttributedString *) string atLocation: (unsigned) startLocation;
- (NSFont *) setTrait: (NSFontTraitMask)trait onFont: (NSFont *) font;

@end

#pragma mark -

@implementation J3ANSIFormattingFilter

+ (J3Filter *) filterWithFormatting: (NSObject <J3Formatter> *) format
{
  return [[[self alloc] initWithFormatting: format] autorelease];
}

- (NSAttributedString *) filter: (NSAttributedString *) string
{
  NSMutableAttributedString *editString = [[NSMutableAttributedString alloc] initWithAttributedString: string];
  
  [self setAttributes: currentAttributes onString: editString fromLocation: 0];
  
  while ([self extractCode: editString])
    ;
  
  [editString autorelease];
  return editString;
}

- (id) initWithFormatting: (NSObject <J3Formatter> *) format
{
  if (!(self = [super init]))
    return nil;
  
  if (!format)
    return nil;

  inCode = false;
  [self at: &formatting put: format];
  [self at: &currentAttributes put: [NSMutableDictionary dictionary]];
  [currentAttributes setValue: [formatting font] forKey: NSFontAttributeName];
  
  return self;
}

- (id) init
{
  return [self initWithFormatting: [J3Formatter formattingForTesting]];
}

@end

#pragma mark -

@implementation J3ANSIFormattingFilter (Private)

- (NSString *) attributeNameForANSICode
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

- (id) attributeValueForANSICodeInString: (NSAttributedString *) string atLocation: (unsigned) location
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

- (BOOL) extractCode: (NSMutableAttributedString *) editString
{
  NSRange codeRange;
  
  if (!inCode)
  {
    codeRange.location = [self scanUpToCodeInString: [editString string]];
    [self at: &ansiCode put: @""];    
  }
  else
    codeRange.location = 0;

  if (inCode || codeRange.location != NSNotFound)
  {
    inCode = YES;
    codeRange.length = [self scanThruEndOfCodeAt: codeRange.location
                                        inString: [editString string]];
    
    if (codeRange.length == NSNotFound)
    {
      codeRange.length = [editString length]  - codeRange.location;
      [editString deleteCharactersInRange: codeRange];
      return NO;
    }
    
    if (codeRange.location < [editString length])
    {
      inCode = NO;
      [editString deleteCharactersInRange: codeRange];
      [self setAttributesInString: editString atLocation: codeRange.location];
      return YES;
    }
  }

  return NO;
}

- (NSFont *) fontInString: (NSAttributedString *) string atLocation: (unsigned) location
{
  return [string attribute: NSFontAttributeName atIndex: location effectiveRange: NULL];
}

- (NSFont *) makeFontBold: (NSFont *) font
{  
  if ([[formatting font] isBold])
    return [font fontWithTrait: NSUnboldFontMask];
  else
    return [font fontWithTrait: NSBoldFontMask];
}

- (NSFont *) makeFontUnbold: (NSFont *) font
{
  if ([[formatting font] isBold])
    return [font fontWithTrait: NSBoldFontMask];
  else
    return [font fontWithTrait: NSUnboldFontMask];
}

- (void) resetAllAttributesInString: (NSMutableAttributedString *) string fromLocation: (unsigned) startLocation
{
  [self resetBackgroundInString: string fromLocation: startLocation];
  [self resetForegroundInString: string fromLocation: startLocation];
  [self resetFontInString: string fromLocation: startLocation];
  [self resetUnderlineInString: string fromLocation: startLocation];
}

- (void) resetBackgroundInString: (NSMutableAttributedString *) string fromLocation: (unsigned) startLocation
{
  [self setAttribute: NSBackgroundColorAttributeName
             toValue: [formatting background]
            inString: string fromLocation: startLocation];
}

- (void) resetFontInString: (NSMutableAttributedString *) string fromLocation: (unsigned) startLocation
{
  [self setAttribute: NSFontAttributeName
             toValue: [formatting font]
            inString: string fromLocation: startLocation];
}

- (void) resetForegroundInString: (NSMutableAttributedString *) string fromLocation: (unsigned) startLocation
{
  [self setAttribute: NSForegroundColorAttributeName
             toValue: [formatting foreground]
            inString: string fromLocation: startLocation];
}

- (void) resetUnderlineInString: (NSMutableAttributedString *) string fromLocation: (unsigned) startLocation
{
  [self setAttribute: NSUnderlineStyleAttributeName
             toValue: [NSNumber numberWithInt: NSNoUnderlineStyle]
            inString: string fromLocation: startLocation];
}

- (void) setAttribute: (NSString *) attribute toValue: (id) value inString: (NSMutableAttributedString *) string fromLocation: (unsigned) startLocation
{
  [string addAttribute: attribute
                 value: value
                 range: NSMakeRange (startLocation, [string length] - startLocation)];
  [currentAttributes setObject: value forKey: attribute];
}

- (void) setAttributes: (NSDictionary *) attributes onString: (NSMutableAttributedString *) string fromLocation: (unsigned) startLocation
{
  for (NSString *key in [attributes allKeys])
  {
    [self setAttribute: key
               toValue: [attributes valueForKey: key]
              inString: string
          fromLocation: startLocation];
  }
}

- (int) scanUpToCodeInString: (NSString *) string
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

- (int) scanThruEndOfCodeAt: (unsigned) codeIndex inString: (NSString *) string
{
  NSScanner *scanner = [NSScanner scannerWithString: string];
  [scanner setScanLocation: codeIndex];
  [scanner setCharactersToBeSkipped:
    [NSCharacterSet characterSetWithCharactersInString: @""]];

  NSCharacterSet *resumeSet =
    [NSCharacterSet characterSetWithCharactersInString:
      @"m"];

  NSString *charactersFromThisScan = @"";
  [scanner scanUpToCharactersFromSet: resumeSet intoString: &charactersFromThisScan];
  [self at: &ansiCode put: [NSString stringWithFormat: @"%@%@", ansiCode, charactersFromThisScan]];
  
  if ([scanner scanLocation] == [string length])
    return NSNotFound;
  else
    return [charactersFromThisScan length] + 1;
}

- (void) setAttributesInString: (NSMutableAttributedString *) string atLocation: (unsigned) startLocation
{
  if ([string length] <= startLocation)
    return;
  
  if ([[ansiCode substringFromIndex: 2] intValue] == 0)
    [self resetAllAttributesInString: string fromLocation: startLocation];
  
  NSString *attributeName = [self attributeNameForANSICode];
  if (!attributeName)
    return;

  id attributeValue = [self attributeValueForANSICodeInString: string atLocation: startLocation];
  
  if (attributeValue)
    [self setAttribute: attributeName toValue: attributeValue inString: string fromLocation: startLocation];
  else if ([attributeName isEqualToString: NSForegroundColorAttributeName])
    [self resetForegroundInString: string fromLocation: startLocation];
  else if ([attributeName isEqualToString: NSBackgroundColorAttributeName])
    [self resetBackgroundInString: string fromLocation: startLocation];
  else
    @throw [NSException exceptionWithName: @"J3ANSIException" reason: @"Did not provide attributeValue" userInfo: nil];
}

- (NSFont *) setTrait: (NSFontTraitMask)trait onFont: (NSFont *) font
{
  return [[NSFontManager sharedFontManager] convertFont: font toHaveTrait: trait];
}

@end

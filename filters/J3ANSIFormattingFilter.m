//
// J3ANSIFormattingFilter.m
//
// Copyright (c) 2010 3James Software.
//

#import "J3ANSIFormattingFilter.h"
#import "J3Formatter.h"
#import "NSFont (Traits).h"

@interface J3ANSIFormattingFilter (Private)

- (NSArray *) attributeNamesForANSICode;
- (NSArray *) attributeValuesForANSICodeInString: (NSAttributedString *) string atLocation: (unsigned) startLocation;
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
- (int) scanThroughEndOfCodeAt: (unsigned) index inString: (NSString *) string;
- (void) setAttributesInString: (NSMutableAttributedString *) string atLocation: (unsigned) startLocation;
- (NSFont *) setTrait: (NSFontTraitMask)trait onFont: (NSFont *) font;

@end

#pragma mark -

@implementation J3ANSIFormattingFilter

+ (J3Filter *) filterWithFormatter: (NSObject <J3Formatter> *) newFormatter
{
  return [[[self alloc] initWithFormatter: newFormatter] autorelease];
}

- (id) initWithFormatter: (NSObject <J3Formatter> *) newFormatter
{
  if (!newFormatter)
    return nil;
  
  if (!(self = [super init]))
    return nil;
  
  ansiCode = nil;
  inCode = false;
  formatter = [newFormatter retain];
  currentAttributes = [[NSMutableDictionary alloc] init];
  [currentAttributes setValue: [formatter font] forKey: NSFontAttributeName];
  
  return self;
}

- (id) init
{
  return [self initWithFormatter: [J3Formatter formatterForTesting]];
}

- (void) dealloc
{
  [ansiCode release];
  [formatter release];
  [currentAttributes release];
  [super dealloc];
}

- (NSAttributedString *) filter: (NSAttributedString *) string
{
  NSMutableAttributedString *editString = [NSMutableAttributedString attributedStringWithAttributedString: string];
  
  [self setAttributes: currentAttributes onString: editString fromLocation: 0];
  
  while ([self extractCode: editString])
    ;
  
  return editString;
}

@end

#pragma mark -

@implementation J3ANSIFormattingFilter (Private)

- (NSArray *) attributeNamesForANSICode
{
  NSArray *codeComponents = [[ansiCode substringFromIndex: 2] componentsSeparatedByString: @";"];
  NSMutableArray *names = [NSMutableArray arrayWithCapacity: [codeComponents count]];
  
  if ([codeComponents count] == 3
      && [[codeComponents objectAtIndex: 1] intValue] == 5)
  {
    if ([[codeComponents objectAtIndex: 0] intValue] == J3ANSIBackground256)
    {
      [names addObject: NSBackgroundColorAttributeName];
      return names;
    }
    else if ([[codeComponents objectAtIndex: 0] intValue] == J3ANSIForeground256)
    {
      [names addObject: NSForegroundColorAttributeName];
      return names;
    }
  }
  
  for (NSString *code in codeComponents)
  {
    switch ([code intValue])
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
        [names addObject: NSBackgroundColorAttributeName];
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
        [names addObject: NSForegroundColorAttributeName];
        break;
        
      case J3ANSIBoldOn:
      case J3ANSIBoldOff:
        [names addObject: NSFontAttributeName];
        break;
        
      case J3ANSIUnderlineOn:
      case J3ANSIUnderlineOff:
        [names addObject: NSUnderlineStyleAttributeName];
        break;
        
      default:
        [names addObject: [NSNull null]];
        break;
    }
  }
  
  return names;
}

- (NSArray *) attributeValuesForANSICodeInString: (NSAttributedString *) string atLocation: (unsigned) location
{
  NSArray *codeComponents = [[ansiCode substringFromIndex: 2] componentsSeparatedByString: @";"];
  NSMutableArray *values = [NSMutableArray arrayWithCapacity: [codeComponents count]];
  
  if ([codeComponents count] == 3
      && [[codeComponents objectAtIndex: 1] intValue] == 5)
  {
    if ([[codeComponents objectAtIndex: 0] intValue] == J3ANSIBackground256
        || [[codeComponents objectAtIndex: 0] intValue] == J3ANSIForeground256)
    {
      int value = [[codeComponents objectAtIndex: 2] intValue];
      
      if (value < 16)
      {
        switch (value)
        {
          case J3ANSI256Black:
          case J3ANSI256BrightBlack:
            [values addObject: [NSColor darkGrayColor]];
            break;
            
          case J3ANSI256Red:
          case J3ANSI256BrightRed:
            [values addObject: [NSColor redColor]];
            break;
            
          case J3ANSI256Green:
          case J3ANSI256BrightGreen:
            [values addObject: [NSColor greenColor]];
            break;
            
          case J3ANSI256Yellow:
          case J3ANSI256BrightYellow:
            [values addObject: [NSColor yellowColor]];
            break;
            
          case J3ANSI256Blue:
          case J3ANSI256BrightBlue:
            [values addObject: [NSColor blueColor]];
            break;
            
          case J3ANSI256Magenta:
          case J3ANSI256BrightMagenta:
            [values addObject: [NSColor magentaColor]];
            break;
            
          case J3ANSI256Cyan:
          case J3ANSI256BrightCyan:
            [values addObject: [NSColor cyanColor]];
            break;
            
          case J3ANSI256White:
          case J3ANSI256BrightWhite:
            [values addObject: [NSColor whiteColor]];
            break;
        }
      }
      else if (value > 15 && value < 232)
      {
        int adjustedValue = value - 16;
        int red = adjustedValue / 36;
        int green = (adjustedValue % 36) / 6;
        int blue = (adjustedValue % 36) % 6;
        
        NSColor *cubeColor = [NSColor colorWithCalibratedRed: 1. / 6. * red
                                                       green: 1. / 6. * green
                                                        blue: 1. / 6. * blue
                                                       alpha: 1.0];
        [values addObject: cubeColor];
      }
      else if (value > 231 && value < 256)
      {
        int adjustedValue = value - 231;
        
        NSColor *grayscaleColor = [NSColor colorWithCalibratedWhite: 1. / 25. * adjustedValue
                                                              alpha: 1.0];
        [values addObject: grayscaleColor];
      }
      
      return values;
    }
  }
  
  for (NSString *code in codeComponents)
  {
    switch ([code intValue])
    {
      case J3ANSIBackgroundBlack:  
      case J3ANSIForegroundBlack:  
        [values addObject: [NSColor darkGrayColor]];
        break;
        
      case J3ANSIBackgroundBlue:
      case J3ANSIForegroundBlue:
        [values addObject: [NSColor blueColor]];
        break;
        
      case J3ANSIBackgroundCyan:
      case J3ANSIForegroundCyan:
        [values addObject: [NSColor cyanColor]];
        break;
        
      case J3ANSIBackgroundDefault:
        [values addObject: [formatter background]];
        break;
        
      case J3ANSIForegroundDefault:
        [values addObject: [formatter foreground]];
        break;
        
      case J3ANSIBackgroundGreen:
      case J3ANSIForegroundGreen:
        [values addObject: [NSColor greenColor]];
        break;
        
      case J3ANSIBackgroundMagenta:
      case J3ANSIForegroundMagenta:
        [values addObject: [NSColor magentaColor]];
        break;
        
      case J3ANSIBackgroundRed:
      case J3ANSIForegroundRed:
        [values addObject: [NSColor redColor]];
        break;
        
      case J3ANSIBackgroundWhite:
      case J3ANSIForegroundWhite:
        [values addObject: [NSColor whiteColor]];
        break;
        
      case J3ANSIBackgroundYellow:
      case J3ANSIForegroundYellow:
        [values addObject: [NSColor yellowColor]];
        break;    
        
      case J3ANSIBoldOn:
        [values addObject: [self makeFontBold: [self fontInString: string atLocation: location]]];
        break;
        
      case J3ANSIBoldOff:
        [values addObject: [self makeFontUnbold: [self fontInString: string atLocation: location]]];
        break;
        
      case J3ANSIUnderlineOn:
        [values addObject: [NSNumber numberWithInt: NSSingleUnderlineStyle]];
        break;
        
      case J3ANSIUnderlineOff:
        [values addObject: [NSNumber numberWithInt: NSNoUnderlineStyle]];
        break;
        
      default:
        [values addObject: [NSNull null]];
        break;
    }
  }
  return values;
}

- (BOOL) extractCode: (NSMutableAttributedString *) editString
{
  NSRange codeRange;
  
  if (!inCode)
  {
    codeRange.location = [self scanUpToCodeInString: [editString string]];
    
    if (ansiCode)
      [ansiCode release];
    ansiCode = [[NSString alloc] initWithString: @""];
  }
  else
    codeRange.location = 0;
  
  if (inCode || codeRange.location != NSNotFound)
  {
    inCode = YES;
    codeRange.length = [self scanThroughEndOfCodeAt: codeRange.location
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
  if ([[formatter font] isBold])
    return [font fontWithTrait: NSUnboldFontMask];
  else
    return [font fontWithTrait: NSBoldFontMask];
}

- (NSFont *) makeFontUnbold: (NSFont *) font
{
  if ([[formatter font] isBold])
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
             toValue: [formatter background]
            inString: string fromLocation: startLocation];
}

- (void) resetFontInString: (NSMutableAttributedString *) string fromLocation: (unsigned) startLocation
{
  [self setAttribute: NSFontAttributeName
             toValue: [formatter font]
            inString: string fromLocation: startLocation];
}

- (void) resetForegroundInString: (NSMutableAttributedString *) string fromLocation: (unsigned) startLocation
{
  [self setAttribute: NSForegroundColorAttributeName
             toValue: [formatter foreground]
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

- (int) scanThroughEndOfCodeAt: (unsigned) codeIndex inString: (NSString *) string
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
  
  NSString *newAnsiCode = [[NSString alloc] initWithFormat: @"%@%@", ansiCode, charactersFromThisScan];
  [ansiCode release];
  ansiCode = newAnsiCode;
  
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
  
  NSArray *attributeNames = [self attributeNamesForANSICode];
  if (!attributeNames)
    return;
  
  NSArray *attributeValues = [self attributeValuesForANSICodeInString: string atLocation: startLocation];
  if (!attributeValues)
    return;
  
  if ([attributeNames count] != [attributeValues count])
    return;
  
  for (unsigned i = 0; i < [attributeNames count]; i++)
  {
    id attributeName = [attributeNames objectAtIndex: i];
    id attributeValue = [attributeValues objectAtIndex: i];
    
    if (attributeName == [NSNull null])
      continue;
    
    if (attributeValue != [NSNull null])
      [self setAttribute: attributeName toValue: attributeValue inString: string fromLocation: startLocation];
    else if ([attributeName isEqualToString: NSForegroundColorAttributeName])
      [self resetForegroundInString: string fromLocation: startLocation];
    else if ([attributeName isEqualToString: NSBackgroundColorAttributeName])
      [self resetBackgroundInString: string fromLocation: startLocation];
    else
      @throw [NSException exceptionWithName: @"J3ANSIException" reason: @"Did not provide attributeValue" userInfo: nil];
  }
}

- (NSFont *) setTrait: (NSFontTraitMask) trait onFont: (NSFont *) font
{
  return [[NSFontManager sharedFontManager] convertFont: font toHaveTrait: trait];
}

@end

//
// J3AnsiFormattingFilter.m
//
// Copyright (c) 2004, 2005 3James Software
//

#import "J3AnsiFormattingFilter.h"
#import "J3Formatting.h"
#import "NSFont (Traits).h"

@interface J3AnsiFormattingFilter (Private)

- (NSString *) attributeNameForAnsiCode;
- (id) attributeValueForAnsiCodeAndString:(NSAttributedString *)string location:(int)location;
- (BOOL) extractCode:(NSMutableAttributedString *)editString;
- (NSFont *) fontInString:(NSAttributedString *)string atLocation:(int)location;
- (NSFont *) makeFontBold:(NSFont *)font;
- (NSFont *) makeFontUnbold:(NSFont *)font;
- (void) resetAllAttributesInString:(NSMutableAttributedString *)string fromLocation:(int)location;
- (void) resetBackgroundInString:(NSMutableAttributedString *)string fromLocation:(int)location;
- (void) resetFontInString:(NSMutableAttributedString *)string fromLocation:(int)location;
- (void) resetForegroundInString:(NSMutableAttributedString *)string fromLocation:(int)location;
- (void) resetUnderlineInString:(NSMutableAttributedString *)string fromLocation:(int)location;
- (void) setAttribute:(NSString *)attribute toValue:(id)value inString:(NSMutableAttributedString *)string fromLocation:(int)location;
- (void) setAttributes:(NSDictionary *)attributes onString:(NSMutableAttributedString *)string fromLocation:(int)location;
- (int) scanUpToCodeInString:(NSString *)string;
- (int) scanThruEndOfCodeAt:(int)index inString:(NSString *)string;
- (void) setAttributesInString:(NSMutableAttributedString *)string atPosition:(int)start;
- (NSFont *) setTrait:(NSFontTraitMask)trait onFont:(NSFont *)font;

@end

@implementation J3AnsiFormattingFilter
+ (J3Filter *) filterWithFormatting:(NSObject <J3Formatting> *)format;
{
  return [[[self alloc] initWithFormatting:format] autorelease];
}


- (NSAttributedString *) filter:(NSAttributedString *)string;
{
  NSMutableAttributedString *editString = [[NSMutableAttributedString alloc] initWithAttributedString:string];
  
  [self setAttributes:currentAttributes onString:editString fromLocation:0];
  
  while ([self extractCode:editString])
    ;
  
  [editString autorelease];
  return editString;
}

- (id) initWithFormatting:(NSObject <J3Formatting> *)format;
{
  if (!(self = [super init]))
    return nil;
  if (!format)
    return nil;
  [self at:&formatting put:format];
  [self at:&currentAttributes put:[NSMutableDictionary dictionary]];
  [currentAttributes setValue:[formatting font] forKey:NSFontAttributeName];
  return self; 
}

- (id) init;
{
  return [self initWithFormatting:[J3Formatting formattingForTesting]];
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
      
    case J3AnsiBoldOn:
    case J3AnsiBoldOff:
      return NSFontAttributeName;
      break;
      
    case J3AnsiUnderlineOn:
    case J3AnsiUnderlineOff:
      return NSUnderlineStyleAttributeName;
      break;
  }
  return nil;
}

- (id) attributeValueForAnsiCodeAndString:(NSAttributedString *)string location:(int)location;
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
      
    case J3AnsiBoldOn:
      return [self makeFontBold:[self fontInString:string atLocation:location]];
      break;
        
    case J3AnsiBoldOff:
      return [self makeFontUnbold:[self fontInString:string atLocation:location]];
      break;
      
    case J3AnsiUnderlineOn:
      return [NSNumber numberWithInt:NSSingleUnderlineStyle];
      break;
      
    case J3AnsiUnderlineOff:
      return [NSNumber numberWithInt:NSNoUnderlineStyle];
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

- (NSFont *) fontInString:(NSAttributedString *)string atLocation:(int)location;
{
  return [string attribute:NSFontAttributeName atIndex:location effectiveRange:NULL];
}

- (NSFont *) makeFontBold:(NSFont *)font;
{  
  if ([[formatting font] isBold])
    return [font fontWithTrait:NSUnboldFontMask];
  else
    return [font fontWithTrait:NSBoldFontMask];
}

- (NSFont *) makeFontUnbold:(NSFont *)font;
{
  if ([[formatting font] isBold])
    return [font fontWithTrait:NSBoldFontMask];
  else
    return [font fontWithTrait:NSUnboldFontMask];
}

- (void) resetAllAttributesInString:(NSMutableAttributedString *)string fromLocation:(int)location;
{
  [self resetBackgroundInString:string fromLocation:location];
  [self resetForegroundInString:string fromLocation:location];
  [self resetFontInString:string fromLocation:location];
  [self resetUnderlineInString:string fromLocation:location];
}

- (void) resetBackgroundInString:(NSMutableAttributedString *)string fromLocation:(int)location;
{
  [self setAttribute:NSBackgroundColorAttributeName toValue:[formatting background] inString:string fromLocation:location];
}

- (void) resetFontInString:(NSMutableAttributedString *)string fromLocation:(int)location;
{
  [self setAttribute:NSFontAttributeName toValue:[formatting font] inString:string fromLocation:location];
}

- (void) resetForegroundInString:(NSMutableAttributedString *)string fromLocation:(int)location;
{
  [self setAttribute:NSForegroundColorAttributeName toValue:[formatting foreground] inString:string fromLocation:location];
}

- (void) resetUnderlineInString:(NSMutableAttributedString *)string fromLocation:(int)location;
{
  [self setAttribute:NSUnderlineStyleAttributeName toValue:[NSNumber numberWithInt:NSNoUnderlineStyle] inString:string fromLocation:location];
}

- (void) setAttribute:(NSString *)attribute toValue:(id)value inString:(NSMutableAttributedString *)string fromLocation:(int)location;
{
  [string addAttribute:attribute value:value range:NSMakeRange (location,[string length] - location)];
  [currentAttributes setObject:value forKey:attribute];
}

- (void) setAttributes:(NSDictionary *)attributes onString:(NSMutableAttributedString *)string fromLocation:(int)location;
{
  NSDictionary * attributeCopy = [attributes copy];
  NSEnumerator * keyEnumerator = [attributeCopy keyEnumerator];
  NSString * key;
  
  while ((key = [keyEnumerator nextObject]))
    [self setAttribute:key toValue:[attributeCopy valueForKey:key] inString:string fromLocation:location];
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
  NSString * attributeName = nil;
  id attributeValue = nil;

  if ([string length] <= start)
    return;
  
  if ([[ansiCode substringFromIndex:2] intValue] == 0)
    [self resetAllAttributesInString:string fromLocation:start];
  
  attributeName = [self attributeNameForAnsiCode];
  if (!attributeName)
    return;

  attributeValue = [self attributeValueForAnsiCodeAndString:string location:start];
  if (attributeValue)
    [self setAttribute:attributeName toValue:attributeValue inString:string fromLocation:start];
  else if ([attributeName isEqualToString:NSForegroundColorAttributeName])
    [self resetForegroundInString:string fromLocation:start];
  else if ([attributeName isEqualToString:NSBackgroundColorAttributeName])
    [self resetBackgroundInString:string fromLocation:start];
  else
    @throw [NSException exceptionWithName:@"J3AnsiException" reason:@"Did not provide attributeValue" userInfo:nil];
}

- (NSFont *) setTrait:(NSFontTraitMask)trait onFont:(NSFont *)font;
{
  NSFontManager * fontManager = [NSFontManager sharedFontManager];
  return [fontManager convertFont:font toHaveTrait:trait];
}

@end

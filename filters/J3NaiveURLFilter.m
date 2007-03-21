//
// J3NaiveURLFilter.m
//
// Copyright (c) 2004, 2005 3James Software
//

#import "J3NaiveURLFilter.h"
#import "categories/NSURL (Allocating).h"

@interface J3NaiveURLFilter (Private)

- (void) linkifyURLs: (NSMutableAttributedString *)editString;
- (NSURL *) normalizedURLForString: (NSString *)string;

@end

@implementation J3NaiveURLFilter

+ (J3Filter *) filter
{
  return [[[self alloc] init] autorelease];
}

- (NSAttributedString *) filter: (NSAttributedString *)string
{
  NSMutableAttributedString *editString = [NSMutableAttributedString attributedStringWithAttributedString: string];
  
  [self linkifyURLs: editString];
  
  return editString;
}

@end

@implementation J3NaiveURLFilter (Private)

- (void) linkifyURLs: (NSMutableAttributedString *)editString
{
  NSString *sourceString = [editString string];
  NSScanner *scanner = [NSScanner scannerWithString: sourceString];
  NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
  NSCharacterSet *nonwhitespace = [whitespace invertedSet];
  NSCharacterSet *skips = [NSCharacterSet characterSetWithCharactersInString: @",.!?()[]{}<>'\""];
  
  while (![scanner isAtEnd])
  {
    NSString *scannedString;
    NSRange scannedRange;
    NSURL *foundURL;
    NSDictionary *linkAttributes;
    unsigned index, length;
    int skipScanLocation = [scanner scanLocation];
    
    while (skipScanLocation < [sourceString length])
    {
      if (![nonwhitespace characterIsMember: [sourceString characterAtIndex: skipScanLocation]])
        skipScanLocation++;
      else
        break;
    }
    
    if (skipScanLocation > [scanner scanLocation])
      [scanner setScanLocation: skipScanLocation];
    
    scannedRange.location = [scanner scanLocation];
    [scanner scanUpToCharactersFromSet: whitespace intoString: &scannedString];
    scannedRange.length = [scanner scanLocation] - scannedRange.location;
    
    index = 0;
    length = [scannedString length];
    
    while (index < length && [skips characterIsMember: [scannedString characterAtIndex: index]])
    {
      index++;
      scannedRange.location++;
      scannedRange.length--;
    }
    
    scannedString = [sourceString substringWithRange: scannedRange];
    index = [scannedString length];
    
    while (index > 0 && [skips characterIsMember: [scannedString characterAtIndex: index - 1]])
    {
      index--;
      scannedRange.length--;
    }
    
    scannedString = [sourceString substringWithRange: scannedRange];
    
    if (foundURL = [self normalizedURLForString: scannedString])
    {
      linkAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
        foundURL, NSLinkAttributeName,
        [NSNumber numberWithInt: NSSingleUnderlineStyle], NSUnderlineStyleAttributeName,
        [NSColor blueColor], NSForegroundColorAttributeName, NULL];
      [editString addAttributes: linkAttributes range: scannedRange];
    }
  }
}

- (NSURL *) normalizedURLForString: (NSString *)string
{
  if ([string hasPrefix: @"http: "])
    return [NSURL URLWithString: string];
  
  if ([string hasPrefix: @"https: "])
    return [NSURL URLWithString: string];
  
  if ([string hasPrefix: @"ftp: "])
    return [NSURL URLWithString: string];
  
  if ([string hasPrefix: @"mailto: "])
    return [NSURL URLWithString: string];
  
  if ([string hasPrefix: @"www."])
    return [NSURL URLWithString: [@"http: //" stringByAppendingString: string]];
  
  if ([string hasPrefix: @"ftp."])
    return [NSURL URLWithString: [@"ftp: //" stringByAppendingString: string]];
  
  if ([string hasSuffix: @".com"] ||
      [string hasSuffix: @".net"] ||
      [string hasSuffix: @".org"] ||
      [string hasSuffix: @".edu"] ||
      [string hasSuffix: @".de"] ||
      [string hasSuffix: @".uk"] ||
      [string hasSuffix: @".cc"])
  {
    if ([string rangeOfString: @"@"].length != 0)
      return [NSURL URLWithString: [@"mailto: " stringByAppendingString: string]];
    else
      return [NSURL URLWithString: [@"http: //" stringByAppendingString: string]];
  }
  
  return nil;
}

@end

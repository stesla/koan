//
// J3URLLinkFilter.m
//
// Copyright (C) 2004 3James Software
//

#import "J3URLLinkFilter.h"

@interface J3URLLinkFilter (Private)

- (void) linkifyURLs:(NSMutableAttributedString *)editString;
- (NSURL *) normalizedURLForString:(NSString *)string;

@end

@implementation J3URLLinkFilter

+ (J3Filter *) filter
{
  return [[[J3URLLinkFilter alloc] init] autorelease];
}

- (NSAttributedString *) filter:(NSAttributedString *)string
{
  NSMutableAttributedString *editString = [NSMutableAttributedString attributedStringWithAttributedString:string];
  
  [self linkifyURLs:editString];
  
  return editString;
}

@end

@implementation J3URLLinkFilter (Private)

- (void) linkifyURLs:(NSMutableAttributedString *)editString
{
  NSScanner *scanner;
  NSString *scanString;
  NSCharacterSet *whitespaceSet;
  
  // Create our scanner and supporting delimiting character set
  scanner = [NSScanner scannerWithString:[editString string]];
  whitespaceSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
  
  // Start Scan
  while (![scanner isAtEnd])
  {
    NSURL *foundURL;
    NSDictionary *linkAttr;
    NSRange scanRange;
    
    // Pull out a token delimited by whitespace or new line
    [scanner scanUpToCharactersFromSet:whitespaceSet intoString:&scanString];
    scanRange.length = [scanString length];
    scanRange.location = [scanner scanLocation] - scanRange.length;
    
    if (foundURL = [self normalizedURLForString:scanString])
    {
      // Apply underline style and link color
      linkAttr = [NSDictionary dictionaryWithObjectsAndKeys:
        foundURL, NSLinkAttributeName,
        [NSNumber numberWithInt:NSSingleUnderlineStyle], NSUnderlineStyleAttributeName,
        [NSColor blueColor], NSForegroundColorAttributeName, NULL ];
      [editString addAttributes:linkAttr range:scanRange];
    }
  }
}

- (NSURL *) normalizedURLForString:(NSString *)string
{
  NSURL *url;
  NSHost *foundHost;
  
  if (([string rangeOfString:@"://"]).length > 0)
  {
    url = [NSURL URLWithString:string];
    foundHost = [NSHost hostWithName:[url host]];
    
    return foundHost ? url : nil;
  }
  else if (([string rangeOfString:@"@"]).length > 0)
  {
    url = [NSURL URLWithString:[@"mailto:" stringByAppendingString:string]];
    foundHost = [NSHost hostWithName:[url host]];
    
    return foundHost ? url : nil;
  }
  else
  {
    url = [NSURL URLWithString:[@"http://" stringByAppendingString:string]];
    foundHost = [NSHost hostWithName:[url host]];
    
    return foundHost ? [NSURL URLWithString:string] : nil;
  }
}

@end

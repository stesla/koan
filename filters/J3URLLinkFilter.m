//
// J3URLLinkFilter.m
//
// Copyright (C) 2004 3James Software
//

#import "J3URLLinkFilter.h"
#import "Categories/NSURL (Allocating).h"

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
  NSString *sourceString = [editString string];
  NSScanner *scanner = [NSScanner scannerWithString:sourceString];
  NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
  NSCharacterSet *nonwhitespace = [whitespace invertedSet];
  NSCharacterSet *skips = [NSCharacterSet characterSetWithCharactersInString:@",.!?()[]{}<>'\""];
  
  while (![scanner isAtEnd])
  {
    NSString *scannedString;
    NSRange scannedRange;
    NSURL *foundURL;
    NSDictionary *linkAttributes;
    unsigned index, length;

    [scanner scanUpToCharactersFromSet:nonwhitespace intoString:NULL];
    scannedRange.location = [scanner scanLocation];
    [scanner scanUpToCharactersFromSet:whitespace intoString:&scannedString];
    scannedRange.length = [scanner scanLocation] - scannedRange.location;
    
    index = 0;
    length = [scannedString length];
    
    while (index < length && [skips characterIsMember:[scannedString characterAtIndex:index]])
    {
      index++;
      scannedRange.location++;
      scannedRange.length--;
    }
    
    scannedString = [sourceString substringWithRange:scannedRange];
    index = [scannedString length];
    
    while (index > 0 && [skips characterIsMember:[scannedString characterAtIndex:index - 1]])
    {
      index--;
      scannedRange.length--;
    }
    
    scannedString = [sourceString substringWithRange:scannedRange];
    
    if (foundURL = [self normalizedURLForString:scannedString])
    {
      foundURL = [foundURL standardizedURL];
      // Apply underline style and link color
      linkAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
        foundURL, NSLinkAttributeName,
        [NSNumber numberWithInt:NSSingleUnderlineStyle], NSUnderlineStyleAttributeName,
        [NSColor blueColor], NSForegroundColorAttributeName, NULL];
      [editString addAttributes:linkAttributes range:scannedRange];
    }
  }
}

- (NSURL *) normalizedURLForString:(NSString *)string
{
  NSURL *url;
  
  if (([string rangeOfString:@"://"]).length != 0)
  {
    NSString *path;
    
    url = [NSURL URLWithString:string];

    if (![NSHost hostWithName:[url host]])
      return nil;
    
    path = [url path];
    if ([path length] == 0) path = @"/";
    
    return [NSURL URLWithScheme:[url scheme] host:[url host] path:path];
  }
  else if (([string rangeOfString:@"@"]).length != 0)
  {
    if ([string hasPrefix:@"mailto:"])
      url = [NSURL URLWithString:string];
    else
      url = [NSURL URLWithString:[@"mailto:" stringByAppendingString:string]];
    
    return url;
  }
  else if ([string hasPrefix:@"ftp."])
  {
    NSString *path;
    
    url = [NSURL URLWithString:[@"ftp://" stringByAppendingString:string]];
    if (![NSHost hostWithName:[url host]])
      return nil;
    
    path = [url path];
    if ([path length] == 0) path = @"/";
    
    return [NSURL URLWithScheme:@"ftp" host:[url host] path:path];
  }
  else
  {
    NSString *path;
    
    url = [NSURL URLWithString:[@"http://" stringByAppendingString:string]];
    if (![NSHost hostWithName:[url host]])
      return nil;
    
    path = [url path];
    if ([path length] == 0) path = @"/";
    
    return [NSURL URLWithScheme:@"http" host:[url host] path:path];
  }
}

@end

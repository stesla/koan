//
// J3URLLinkFilterTests.m
//
// Copyright (C) 2004 3James Software
//

#import "J3URLLinkFilterTests.h"
#import "J3URLLinkFilter.h"

@interface J3URLLinkFilterTests (Private)

- (void) assertInput:(NSString *)input producesLink:(NSURL *)link forRange:(NSRange)range;

@end

#pragma mark -

@implementation J3URLLinkFilterTests (Private)

- (void) assertInput:(NSString *)input producesLink:(NSURL *)link forRange:(NSRange)range
{
  NSAttributedString *attributedInput = 
    [NSAttributedString attributedStringWithString:input];
  NSAttributedString *attributedOutput =
    [queue processAttributedString:attributedInput];
  NSDictionary *attributes;
  NSURL *foundLink;
  NSRange foundRange;
  
  [self assert:[attributedInput string]
        equals:[attributedOutput string]
       message:@"Strings not equal."];  
  
  attributes = [attributedOutput attributesAtIndex:0
                             longestEffectiveRange:&foundRange
                                           inRange:NSMakeRange (0, [attributedOutput length])];
  
  foundLink = [attributes objectForKey:NSLinkAttributeName];
  
  [self assert:foundLink
        equals:link
       message:@"Links don't match."];
  
  if (foundLink)
  {
    [self assert:[NSNumber numberWithUnsignedInt:foundRange.location]
          equals:[NSNumber numberWithUnsignedInt:range.location]
         message:@"Range locations don't match."];
    
    [self assert:[NSNumber numberWithUnsignedInt:foundRange.length]
          equals:[NSNumber numberWithUnsignedInt:range.length]
         message:@"Range lengths don't match."];
  }
}

@end

#pragma mark -

@implementation J3URLLinkFilterTests

- (void) setUp
{
  queue = [[J3FilterQueue alloc] init];
  [queue addFilter:[J3URLLinkFilter filter]];
}

- (void) tearDown
{
  [queue release];
}

- (void) testNoLink
{
  [self assertInput:@"nonsense"
       producesLink:nil
           forRange:NSMakeRange (NSNotFound, 0)];
}

- (void) testCanonicalLink
{
  NSString *input = @"http://www.google.com/";
  
  [self assertInput:input
       producesLink:[NSURL URLWithString:@"http://www.google.com/"]
           forRange:[input rangeOfString:@"http://www.google.com/"]];
}

@end

//
// J3NaiveURLFilterTests.m
//
// Copyright (c) 2004, 2005 3James Software
//

#import "J3NaiveURLFilterTests.h"
#import "J3NaiveURLFilter.h"
#import "categories/NSURL (Allocating).h"

@interface J3NaiveURLFilterTests (Private)

- (void) assertInput:(NSString *)input producesLink:(NSURL *)link forRange:(NSRange)range;

@end

#pragma mark -

@implementation J3NaiveURLFilterTests (Private)

- (void) assertInput:(NSString *)input producesLink:(NSURL *)link forRange:(NSRange)range
{
  NSAttributedString *attributedInput = 
  [NSAttributedString attributedStringWithString:input];
  NSAttributedString *attributedOutput =
    [queue processAttributedString:attributedInput];
  NSURL *foundLink;
  NSRange foundRange;
  
  [self assert:[attributedInput string]
        equals:[attributedOutput string]
       message:@"Strings not equal."];  
  
  if (range.location != 0)
  {
    foundLink = [attributedOutput attribute:NSLinkAttributeName
                                    atIndex:range.location - 1
                      longestEffectiveRange:&foundRange
                                    inRange:NSMakeRange (0, [input length])];
    
    [self assertFalse:[foundLink isEqual:link]
              message:@"Preceding character matches link and shouldn't."];
  }
  
  if (NSMaxRange (range) < [input length])
  {
    foundLink = [attributedOutput attribute:NSLinkAttributeName
                                    atIndex:NSMaxRange (range)
                      longestEffectiveRange:&foundRange
                                    inRange:NSMakeRange (0, [input length])];
    
    [self assertFalse:[foundLink isEqual:link]
              message:@"Following character matches link and shouldn't."];
  }
  
  foundLink = [attributedOutput attribute:NSLinkAttributeName
                                  atIndex:range.location
                    longestEffectiveRange:&foundRange
                                  inRange:NSMakeRange (0, [input length])];
  
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

@implementation J3NaiveURLFilterTests

- (void) setUp
{
  queue = [[J3FilterQueue alloc] init];
  [queue addFilter:[J3NaiveURLFilter filter]];
}

- (void) tearDown
{
  [queue release];
}

- (void) testNoLink
{
  [self assertInput:@"nonsense"
       producesLink:nil
           forRange:NSMakeRange (0, [@"nonsense" length])];
}

- (void) testCanonicalLink
{
  NSString *input = @"http://www.google.com/";
  
  [self assertInput:input
       producesLink:[NSURL URLWithString:@"http://www.google.com/"]
           forRange:[input rangeOfString:@"http://www.google.com/"]];
}

- (void) testSlashlessLink
{
  NSString *input = @"http://www.google.com";
  
  [self assertInput:input
       producesLink:[NSURL URLWithString:@"http://www.google.com"]
           forRange:[input rangeOfString:@"http://www.google.com"]];
}

- (void) testInformalLink
{
  NSString *input = @"www.google.com";
  
  [self assertInput:input
       producesLink:[NSURL URLWithString:@"http://www.google.com"]
           forRange:[input rangeOfString:@"www.google.com"]];
}

- (void) testLinkAtStart
{
  NSString *input = @"www.3james.com is the link";
  
  [self assertInput:input
       producesLink:[NSURL URLWithString:@"http://www.3james.com"]
           forRange:[input rangeOfString:@"www.3james.com"]];
}

- (void) testLinkAtEnd
{
  NSString *input = @"The link is www.3james.com";
  
  [self assertInput:input
       producesLink:[NSURL URLWithString:@"http://www.3james.com"]
           forRange:[input rangeOfString:@"www.3james.com"]];
}

- (void) testLinkInMiddle
{
  NSString *input = @"I heard that www.3james.com is the link";
  
  [self assertInput:input
       producesLink:[NSURL URLWithString:@"http://www.3james.com"]
           forRange:[input rangeOfString:@"www.3james.com"]];
}

- (void) testLinkInSeparators
{
  NSString *input = @" <www.google.com> ";
  
  [self assertInput:input
       producesLink:[NSURL URLWithString:@"http://www.google.com"]
           forRange:[input rangeOfString:@"www.google.com"]];
}

- (void) testLinkFollowedByPunctuation
{
  NSString *input = @"Is the link www.google.com?";
  
  [self assertInput:input
       producesLink:[NSURL URLWithString:@"http://www.google.com"]
           forRange:[input rangeOfString:@"www.google.com"]];
}

- (void) testCanonicalEmail
{
  NSString *input = @"mailto:tyler@3james.com";
  
  [self assertInput:input
       producesLink:[NSURL URLWithString:@"mailto:tyler@3james.com"]
           forRange:[input rangeOfString:@"mailto:tyler@3james.com"]];
}

- (void) testInformalEmail
{
  NSString *input = @"tyler@3james.com";
  
  [self assertInput:input
       producesLink:[NSURL URLWithString:@"mailto:tyler@3james.com"]
           forRange:[input rangeOfString:@"tyler@3james.com"]];
}

@end

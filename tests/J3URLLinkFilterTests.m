//
// J3URLLinkFilterTests.m
//
// Copyright (C) 2004 3James Software
//

#import "J3URLLinkFilterTests.h"
#import "J3URLLinkFilter.h"
#import "Categories/NSURL (Allocating).h"

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
  
  [self assert:[foundLink scheme]
        equals:[link scheme]
       message:@"Schemes don't match."];
  [self assert:[foundLink host]
        equals:[link host]
       message:@"Hosts don't match."];
  [self assert:[foundLink path]
        equals:[link path]
       message:@"Paths don't match."];
  
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
       producesLink:[NSURL URLWithScheme:@"http" host:@"www.google.com" path:@"/"]
           forRange:[input rangeOfString:@"http://www.google.com/"]];
}

- (void) testSlashlessLink
{
  NSString *input = @"http://www.google.com";
  
  [self assertInput:input
       producesLink:[NSURL URLWithScheme:@"http" host:@"www.google.com" path:@"/"]
           forRange:[input rangeOfString:@"http://www.google.com"]];
}

- (void) testInformalLink
{
  NSString *input = @"www.google.com";
  
  [self assertInput:input
       producesLink:[NSURL URLWithScheme:@"http" host:@"www.google.com" path:@"/"]
           forRange:[input rangeOfString:@"www.google.com"]];
}

- (void) testNonexistentLink
{
  NSString *input = @"www.thissitecertainlydoesnotexist.com";
  
  [self assertInput:input
       producesLink:nil
           forRange:NSMakeRange (NSNotFound, 0)];
}

- (void) testUnusualToplevelLink
{
  NSString *input = @"www.arete.cc";
  
  [self assertInput:input
       producesLink:[NSURL URLWithScheme:@"http" host:@"www.arete.cc" path:@"/"]
           forRange:[input rangeOfString:@"www.arete.cc"]];
}

- (void) testLinkAtStart
{
  NSString *input = @"www.3james.com is the link";
  
  [self assertInput:input
       producesLink:[NSURL URLWithScheme:@"http" host:@"www.3james.com" path:@"/"]
           forRange:[input rangeOfString:@"www.3james.com"]];
}

- (void) testLinkAtEnd
{
  NSString *input = @"The link is www.3james.com";
  
  [self assertInput:input
       producesLink:[NSURL URLWithScheme:@"http" host:@"www.3james.com" path:@"/"]
           forRange:[input rangeOfString:@"www.3james.com"]];
}

- (void) testLinkInMiddle
{
  NSString *input = @"I heard that www.3james.com is the link";
  
  [self assertInput:input
       producesLink:[NSURL URLWithScheme:@"http" host:@"www.3james.com" path:@"/"]
           forRange:[input rangeOfString:@"www.3james.com"]];
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

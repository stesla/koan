//
// J3AttributedStringTransformerTests.m
//
// Copyright (c) 2005 3James Software
//

#import "J3AttributedStringTransformerTests.h"
#import "TestCase (NSAttributedStringAssertions).h"
#import "J3AttributedStringTransformer.h"

@implementation J3AttributedStringTransformerTests

- (void) setUp
{
  transformer = [J3AttributedStringTransformer transformer];
  input = [NSAttributedString attributedStringWithString:@"Quux"];
  output = nil;
  
  // set these to Bad Numbers to make it obvious 
  // when we haven't initialized them
  range.location = -1;
  range.length = -1;
}

- (void) testSetsAttributeToEndOfString
{
  range.location = 1;
  range.length = [input length] - range.location;

  [transformer changeAttributeWithName:@"Foo" 
                               toValue:@"Bar"
                            atLocation:range.location];
  output = [transformer transform:input];
  
  [self assertAttribute:@"Foo"
                 equals:@"Bar"
     inAttributedString:output
              withRange:range];
}

- (void) testSetsThreeAttributes
{
  [transformer changeAttributeWithName:@"Foo" 
                               toValue:@"Bar"
                            atLocation:1];
  [transformer changeAttributeWithName:@"Foo" 
                               toValue:@"Baz"
                            atLocation:2];
  [transformer changeAttributeWithName:@"Foo" 
                               toValue:@"Quux"
                            atLocation:3];
  output = [transformer transform:input];

  range.length = 1;
  range.location = 1;
  [self assertAttribute:@"Foo"
                 equals:@"Bar"
     inAttributedString:output
              withRange:range];
  range.location = 2;
  [self assertAttribute:@"Foo"
                 equals:@"Baz"
     inAttributedString:output
              withRange:range];
  range.location = 3;
  [self assertAttribute:@"Foo"
                 equals:@"Quux"
     inAttributedString:output
              withRange:range];
}

- (void) testTransformLocationBeyondEndOfString
{
  [transformer changeAttributeWithName:@"Foo" toValue:@"Bar" atLocation:20];
  output = [transformer transform:input];
  range.location = 1;
  range.length = [input length] - range.location;
  [self assertAttribute:@"Foo"
                 equals:nil
     inAttributedString:output
              withRange:range];
}

- (void) testTwoPropertiesAtSameLocation
{
  [transformer changeAttributeWithName:@"Foo" toValue:@"Bar" atLocation:1];
  [transformer changeAttributeWithName:@"MagicWord" toValue:@"xyzzy" atLocation:1];
  output = [transformer transform:input];
  range.location = 1;
  range.length = [input length] - range.location;
  [self assertAttribute:@"Foo"
                 equals:@"Bar"
     inAttributedString:output
              withRange:range];
  [self assertAttribute:@"MagicWord"
                 equals:@"xyzzy"
     inAttributedString:output
              withRange:range];
}

/*
- (void) testTwoPropertiesAtSubsequentLocations
{
  [transformer changeAttributeWithName:@"Foo" toValue:@"Bar" atLocation:1];
  [transformer changeAttributeWithName:@"MagicWord" toValue:@"xyzzy" atLocation:2];
  output = [transformer transform:input];
  
  range.location = 1;
  range.length = [input length] - range.location;
  [self assertAttribute:@"Foo"
                 equals:@"Bar"
               inString:output
              withRange:range
                message:@"Foo"];
  range.location = 2;
  range.length = [input length] - range.location;
  [self assertAttribute:@"MagicWord"
                 equals:@"xyzzy"
               inString:output
              withRange:range
                message:@"MagicWord"];
}*/

@end

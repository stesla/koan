//
//  J3AttributedStringTransformerTests.m
//  Koan
//
//  Created by Samuel on 2/1/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "J3AttributedStringTransformerTests.h"
#import "TestCase (NSAttributedStringAssertions).h"
#import "J3AttributedStringTransformer.h"

@implementation J3AttributedStringTransformerTests

- (void) testSetsAttributeToEndOfString
{
  J3AttributedStringTransformer *transformer = 
    [J3AttributedStringTransformer transformer];
  NSAttributedString *input = 
    [NSAttributedString attributedStringWithString:@"Quux"];
  NSAttributedString *output;
  NSRange range;

  range.location = 1;
  range.length = [input length] - range.location;

  [transformer changeAttributeWithName:@"Foo" 
                               toValue:@"Bar"
                            atLocation:range.location];
  output = [transformer transform:input];
  
  [self assertAttribute:@"Foo"
                 equals:@"Bar"
               inString:output
              withRange:range];
}

@end

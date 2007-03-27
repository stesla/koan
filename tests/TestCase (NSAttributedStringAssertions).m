//
// J3TestCase (NSAttributedStringAssertions).m
//
// Copyright (c) 2005, 2006, 2007 3James Software
//

#import "TestCase (NSAttributedStringAssertions).h"

@implementation J3TestCase (NSAttributedStringAssertions)

- (void) assertAttributedString: (NSAttributedString *) actualString
                   equalsString: (NSString *) expectedString
                        message: (NSString *) message
{
  [self assertTrue: [[actualString string] isEqualToString: expectedString] message: message];  
}

- (void) assertAttributedString: (NSAttributedString *) actualString
                   equalsString: (NSString *) expected
{
  [self assertAttributedString: actualString equalsString: expected message: nil];
}

- (void) assertAttributesTheSameInString: (NSAttributedString *) string
                               withRange: (NSRange)range
                                 message: (NSString *) message
{
  NSRange result;
  
  [string attributesAtIndex: range.location
      longestEffectiveRange: &result
                    inRange: range];
  
  [self assertInt: result.length
           equals: range.length
          message: message];
}

- (void) assertAttributesTheSameInString: (NSAttributedString *) string
                               withRange: (NSRange)range
{
  [self assertAttributesTheSameInString: string
                              withRange: range
                                message: nil];
}

- (void) assertAttribute: (NSString *) attributeName
                  equals: (id) expectedValue
      inAttributedString: (NSAttributedString *) string
                 atIndex: (int) index
                 message: (NSString *) message
{
  NSDictionary *attributes = [string attributesAtIndex: index
                                        effectiveRange: NULL];
  [self assert: [attributes objectForKey: attributeName]
        equals: expectedValue
       message: message];
}

- (void) assertAttribute: (NSString *) attributeName
                  equals: (id) expectedValue
      inAttributedString: (NSAttributedString *) string
                 atIndex: (int) index
{
  [self assertAttribute: attributeName
                 equals: expectedValue
     inAttributedString: string
                atIndex: index
                message: nil];
}

- (void) assertAttribute: (NSString *) attributeName
                  equals: (id) expectedValue
      inAttributedString: (NSAttributedString*) string
               withRange: (NSRange)range
                 message: (NSString *) message
{
  [self assertAttribute: attributeName
                 equals: expectedValue
     inAttributedString: string
                atIndex: range.location];
  [self assertAttributesTheSameInString: string withRange: range message: message];
}

- (void) assertAttribute: (NSString *) attributeName
                  equals: (id) expectedValue
      inAttributedString: (NSAttributedString*) string
               withRange: (NSRange)range
{
  [self assertAttribute: attributeName
                 equals: expectedValue
     inAttributedString: string
              withRange: range
                message: nil];
}

@end

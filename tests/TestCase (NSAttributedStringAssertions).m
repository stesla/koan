//
// TestCase (NSAttributedStringAssertions).m
//
// Copyright (c) 2005 3James Software
//

#import "TestCase (NSAttributedStringAssertions).h"

@implementation TestCase (NSAttributedStringAssertions)

- (void) assertAttributedString:(NSAttributedString *)actual 
                   equalsString:(NSString *)expected
                        message:(NSString *)message
{
  [self assert:[actual string] equals:expected message:message];  
}

- (void) assertAttributedString:(NSAttributedString *)actual 
                   equalsString:(NSString *)expected
{
  [self assertAttributedString:actual equalsString:expected message:nil];
}

- (void) assertAttributesTheSameInString:(NSAttributedString *)string
                               withRange:(NSRange)range
                                 message:(NSString *)message
{
  NSRange result;
  
  [string attributesAtIndex:range.location
      longestEffectiveRange:&result
                    inRange:range];
  
  [self assertInt:result.length
           equals:range.length
          message:message];
}

- (void) assertAttributesTheSameInString:(NSAttributedString *)string
                               withRange:(NSRange)range
{
  [self assertAttributesTheSameInString:string
                              withRange:range
                                message:nil];
}

- (void) assertAttribute:(NSString *)aName
                  equals:(id)object
      inAttributedString:(NSAttributedString *)string
                 atIndex:(int)index
                 message:(NSString *)message
{
  NSDictionary *attributes = [string attributesAtIndex:index
                                        effectiveRange:NULL];
  [self assert:[attributes objectForKey:aName]
        equals:object
       message:message];
}

- (void) assertAttribute:(NSString *)aName
                  equals:(id)object
      inAttributedString:(NSAttributedString *)string
                 atIndex:(int)index
{
  [self assertAttribute:aName
                 equals:object
     inAttributedString:string
                atIndex:index
                message:nil];
}

- (void) assertAttribute:(NSString *)aName
                  equals:(id)object
      inAttributedString:(NSAttributedString*)string
               withRange:(NSRange)range
                 message:(NSString *)message
{
  [self assertAttribute:aName
                 equals:object
     inAttributedString:string
                atIndex:range.location];
  [self assertAttributesTheSameInString:string withRange:range message:message];
}

- (void) assertAttribute:(NSString *)aName
                  equals:(id)object
      inAttributedString:(NSAttributedString*)string
               withRange:(NSRange)range
{
  [self assertAttribute:aName
                 equals:object
     inAttributedString:string
              withRange:range
                message:nil];
}

@end

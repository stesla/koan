//
// TestCase (NSAttributedStringAssertions).h
//
// Copyright (c) 2005 3James Software
//

#import <Cocoa/Cocoa.h>
#import <ObjcUnit/ObjcUnit.h>

@interface TestCase (NSAttributedStringAssertions)

- (void) assertAttributedString:(NSAttributedString *)actual 
                   equalsString:(NSString *)expected;

- (void) assertAttributedString:(NSAttributedString *)actual 
                   equalsString:(NSString *)expected
                        message:(NSString *)message;

- (void) assertAttributesTheSameInString:(NSAttributedString *)string
                               withRange:(NSRange)range
                                 message:(NSString *)message;

- (void) assertAttributesTheSameInString:(NSAttributedString *)string
                               withRange:(NSRange)range;

- (void) assertAttribute:(NSString *)aName
                  equals:(id)object
      inAttributedString:(NSAttributedString *)string
                 atIndex:(int)index
                 message:(NSString *)message;

- (void) assertAttribute:(NSString *)aName
                  equals:(id)object
      inAttributedString:(NSAttributedString *)string
                 atIndex:(int)index;

- (void) assertAttribute:(NSString *)aName
                  equals:(id)object
      inAttributedString:(NSAttributedString*)string
               withRange:(NSRange)range
                 message:(NSString *)message;

- (void) assertAttribute:(NSString *)aName
                  equals:(id)object
      inAttributedString:(NSAttributedString*)string
               withRange:(NSRange)range;

@end

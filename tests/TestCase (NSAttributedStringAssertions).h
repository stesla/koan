//
//  TestCase (NSAttributedStringAssertions).h
//  Koan
//
//  Created by Samuel on 1/26/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ObjcUnit/ObjcUnit.h>

@interface TestCase (NSAttributedStringAssertions)
- (void) assertAttributedString:(NSAttributedString *)actual 
                   stringEquals:(NSString *)expected;
- (void) assertAttributedString:(NSAttributedString *)actual 
                   stringEquals:(NSString *)expected
                        message:(NSString *)message;
- (void) assertAttributesTheSameInString:(NSAttributedString *)string
                               withRange:(NSRange)range
                                 message:(NSString *)message;
- (void) assertAttributesTheSameInString:(NSAttributedString *)string
                               withRange:(NSRange)range;
- (void) assertAttribute:(NSString *)aName
                  equals:(id)object
                inString:(NSAttributedString *)string
                 atIndex:(int)index
                 message:(NSString *)message;
- (void) assertAttribute:(NSString *)aName
                  equals:(id)object
                inString:(NSAttributedString *)string
                 atIndex:(int)index;
- (void) assertAttribute:(NSString *)aName
                  equals:(id)object
                inString:(NSAttributedString*)string
               withRange:(NSRange)range
                 message:(NSString *)message;
- (void) assertAttribute:(NSString *)aName
                  equals:(id)object
                inString:(NSAttributedString*)string
               withRange:(NSRange)range;
@end

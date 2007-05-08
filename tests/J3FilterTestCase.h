//
// J3FilterTestCase.h
//
// Copyright (c) 2007 3James Software.
//

#import <J3Testing/J3TestCase.h>

#import "J3Filter.h"

@interface J3FilterTestCase : J3TestCase
{
  J3FilterQueue *queue;
}

- (void) assertInput: (NSString *) input hasOutput: (NSString *) output;
- (void) assertInput: (NSString *) input
           hasOutput: (NSString *) output
             message: (NSString *) message;
- (NSMutableAttributedString *) constructAttributedStringForString: (NSString *) string;

@end

//
// J3AttributedStringTransformerTests.h
//
// Copyright (c) 2005 3James Software
//

#import <Cocoa/Cocoa.h>
#import "J3TestCase.h"

@class J3AttributedStringTransformer;

@interface J3AttributedStringTransformerTests : J3TestCase
{
  J3AttributedStringTransformer *transformer;
  NSAttributedString *input;
  NSAttributedString *output;
  NSRange range;
}

@end

//
// J3AttributedStringTransformerTests.h
//
// Copyright (c) 2005 3James Software
//

#import <Cocoa/Cocoa.h>
#import <ObjcUnit/ObjcUnit.h>

@class J3AttributedStringTransformer;

@interface J3AttributedStringTransformerTests : TestCase
{
  J3AttributedStringTransformer *transformer;
  NSAttributedString *input;
  NSAttributedString *output;
  NSRange range;
}

@end

//
//  J3AttributedStringTransformerTests.h
//  Koan
//
//  Created by Samuel on 2/1/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
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

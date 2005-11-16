//
//  J3WriteBufferTests.m
//  Koan
//
//  Created by Samuel Tesla on 11/15/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "J3WriteBufferTests.h"
#import "J3WriteBuffer.h"

@implementation J3WriteBufferTests
- (void) testWriteToNowhere
{
  J3WriteBuffer * buffer = [J3WriteBuffer buffer];
  [buffer appendString:@"foo"];
  [buffer write];
  [self assert:[buffer stringValue] equals:@""];
}
@end

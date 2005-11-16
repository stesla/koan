//
//  J3WriteBufferTests.h
//  Koan
//
//  Created by Samuel Tesla on 11/15/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "J3ByteDestination.h"

@class J3WriteBuffer;

@interface J3WriteBufferTests : TestCase <J3ByteDestination>
{
  J3WriteBuffer * buffer;
  unsigned int lengthWritten;
  NSMutableData * output;
}
@end

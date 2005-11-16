//
//  J3LineBufferTests.h
//  NewTelnet
//
//  Created by Samuel Tesla on 11/10/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ObjcUnit/ObjcUnit.h>
#import "J3LineBuffer.h"

@interface J3LineBufferTests : TestCase <J3LineBufferDelegate>
{
  NSString * line;
  J3LineBuffer * buffer;
}

@end

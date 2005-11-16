//
//  J3SocketWriteBufferTests.m
//  Koan
//
//  Created by Samuel Tesla on 11/15/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "J3SocketWriteBufferTests.h"
#import "J3SocketWriteBuffer.h"

@implementation J3SocketWriteBufferTests
- (void) testWriteToNowhere
{
  J3SocketWriteBuffer * buffer = [J3SocketWriteBuffer buffer];
  [buffer appendString:@"foo"];
  [buffer write];
  [self assert:[buffer stringValue] equals:@""];
}
@end

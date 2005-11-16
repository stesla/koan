//
//  J3LineBufferTests.m
//  NewTelnet
//
//  Created by Samuel Tesla on 11/10/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "J3LineBufferTests.h"

@interface J3LineBufferTests (Private)
- (void) bufferString:(NSString *)string;
@end

@implementation J3LineBufferTests
- (void) lineBufferHasReadLine:(J3LineBuffer *)aBuffer;
{
  line = [aBuffer readLine];
}

- (void) setUp;
{
  buffer = [[J3LineBuffer alloc] init];  
}

- (void) tearDown;
{
  [buffer release];
}

- (void) testReadLine;
{
  [self bufferString:@"ab\n"];
  [self assert:[buffer readLine] equals:@"ab\n"];
  [self bufferString:@"de\n"];
  [self assert:[buffer readLine] equals:@"de\n"];
}

- (void) testDelegate;
{
  [buffer setDelegate:self];
  [self bufferString:@"ab\n"];
  [self assert:line equals:@"ab\n"];
}
@end

@implementation J3LineBufferTests (Private)
- (void) bufferString:(NSString *)string;
{
  [buffer appendString:string];
}
@end

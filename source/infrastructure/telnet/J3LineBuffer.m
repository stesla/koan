//
//  J3LineBuffer.m
//  NewTelnet
//
//  Created by Samuel Tesla on 11/10/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "J3LineBuffer.h"

@interface J3LineBuffer (Private)
- (void) hasReadLine;
@end

@implementation J3LineBuffer
- (void) append:(uint8_t)byte
{
  [super append:byte];
  if (byte == '\n')
    [self hasReadLine];
}

- (NSString *) readLine;
{
  NSString * result = [self stringValue];
  [self clear];
  return result;
}

- (void) setDelegate:(id <NSObject, J3LineBufferDelegate>)object;
{
  [self at:&delegate put:object];
}
@end

@implementation J3LineBuffer (Private)
- (void) hasReadLine;
{
  if (!delegate || ![delegate respondsToSelector:@selector(lineBufferHasReadLine:)])
    return;
  [delegate lineBufferHasReadLine:self];
}
@end

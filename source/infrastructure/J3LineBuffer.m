//
// J3LineBuffer.m
//
// Copyright (c) 2005 3James Software
//

#import "J3LineBuffer.h"

@interface J3LineBuffer (Private)

- (void) hasReadLine;

@end

#pragma mark -

@implementation J3LineBuffer

- (NSString *) readLine
{
  NSString *result = [self stringValue];
  [self clear];
  return result;
}

- (void) setDelegate:(NSObject <J3LineBufferDelegate> *)object
{
  [self at:&delegate put:object];
}

#pragma mark -
#pragma mark Overrides

- (void) append:(uint8_t)byte
{
  [super append:byte];
  if (byte == (uint8_t) '\n')
    [self hasReadLine];
}

- (void) flush;
{
  while (![self isEmpty])
    [self hasReadLine];
}
@end

#pragma mark -

@implementation J3LineBuffer (Private)

- (void) hasReadLine
{
  if ([delegate respondsToSelector:@selector(lineBufferHasReadLine:)])
    [delegate lineBufferHasReadLine:self];
}

@end

//
// MUTextView.m
//
// Copyright (c) 2005 3James Software
//

#import "MUTextView.h"

@implementation MUTextView

- (void) insertText:(id)string
{
  BOOL result;
  
  if ([[self delegate] respondsToSelector:@selector(textView:insertText:)])
    result = [[self delegate] textView:self insertText:string];
  
  if (!result)
    [super insertText:string];
}

@end

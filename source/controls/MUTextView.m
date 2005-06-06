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

- (IBAction) paste:(id)sender
{
  [self pasteAsPlainText:sender];
}

- (IBAction) pasteAsRichText:(id)sender
{
  [self pasteAsPlainText:sender];
}

@end

//
// MUForwardingTextView.m
//
// Copyright (C) 2004 3James Software
//

#import "MUForwardingTextView.h"

@implementation MUForwardingTextView

- (void )insertText:(id)string
{
  [targetTextView insertText:string];
  [[self window] makeFirstResponder:targetTextView];
}

@end
//
// MUForwardingTextView.h
//
// Copyright (C) 2004 3James Software
//

#import <Cocoa/Cocoa.h>

@interface MUForwardingTextView : NSTextView
{
  IBOutlet NSTextView *targetTextView;
}

@end

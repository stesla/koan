//
// MUForwardingTextView.h
//
// Copyright (C) 2004, 2005 3James Software
//

#import <Cocoa/Cocoa.h>

@interface MUForwardingTextView : NSTextView
{
  IBOutlet NSTextView *targetTextView;
}

@end

@interface NSObject (MUForwardingTextViewDelegate)

- (NSCursor *) cursorForLink:(NSObject *)linkObject
                     atIndex:(unsigned)charIndex
                  ofTextView:(NSTextView *)aTextView;

@end

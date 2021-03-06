//
// MUTextView.h
//
// Copyright (c) 2010 3James Software.
//

#import <Cocoa/Cocoa.h>

@interface MUTextView : NSTextView

@end

#pragma mark -

@interface NSObject (MUTextViewDelegate)

- (BOOL) textView: (MUTextView *) textView insertText: (id) string;
- (BOOL) textView: (MUTextView *) textView pasteAsPlainText: (id) originalSender;

@end

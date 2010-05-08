//
// MULogBrowserWindowController.h
//
// Copyright (c) 2010 3James Software.
//

#import <Cocoa/Cocoa.h>

@interface MULogBrowserWindowController : NSWindowController
{
  IBOutlet NSTextView *textView;
}

+ (id) sharedLogBrowserWindowController;

@end

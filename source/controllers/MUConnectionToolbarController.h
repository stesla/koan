//
// MUConnectionToolbarController.h
//
// Copyright (C) 2004 3James Software
//

#import <Cocoa/Cocoa.h>

@interface MUConnectionToolbarController : NSObject
{
  NSToolbar *toolbar;
  NSMutableDictionary *items; // All items that are allowed to be in the toolbar.
  
  IBOutlet NSWindow *window;
  IBOutlet NSWindowController *windowController;
}

@end

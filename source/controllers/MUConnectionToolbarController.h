//
// MUConnectionToolbarController.h
//
// Copyright (c) 2004, 2005 3James Software
//

#import <Cocoa/Cocoa.h>

@interface MUConnectionToolbarController : NSObject
{
  NSToolbar *toolbar;
  
  IBOutlet NSWindow *window;
  IBOutlet NSWindowController *windowController;
}

@end

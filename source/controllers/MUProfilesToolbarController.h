//
// MUProfilesToolbarController.h
//
// Copyright (c) 2007 3James Software.
//

#import <Cocoa/Cocoa.h>

@interface MUProfilesToolbarController : NSObject
{
  NSToolbar *toolbar;
  
  IBOutlet NSWindow *window;
  IBOutlet NSWindowController *windowController;
}

@end

//
// MUProfilesController.h
//
// Copyright (C) 2004 3James Software
//

#import <Cocoa/Cocoa.h>

@interface MUProfilesController : NSWindowController
{
  IBOutlet NSWindow *worldEditorSheet;
  IBOutlet NSWindow *playerEditorSheet;
  
  IBOutlet NSTextField *worldNameField;
  IBOutlet NSTextField *worldHostnameField;
  IBOutlet NSTextField *worldPortField;
  IBOutlet NSTextField *worldURLField;
  IBOutlet NSButton *worldSaveButton;
  
  IBOutlet NSTextField *playerNameField;
  IBOutlet NSSecureTextField *playerPasswordField;
  IBOutlet NSButton *playerSaveButton;
}

- (IBAction) addPlayer:(id)sender;
- (IBAction) addWorld:(id)sender;
- (IBAction) editPlayer:(id)sender;
- (IBAction) editWorld:(id)sender;
- (IBAction) endEditingPlayer:(id)sender;
- (IBAction) endEditingWorld:(id)sender;

@end

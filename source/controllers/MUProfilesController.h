//
// MUProfilesController.h
//
// Copyright (C) 2004 3James Software
//

#import <Cocoa/Cocoa.h>

@interface MUProfilesController : NSWindowController
{
  IBOutlet NSTableView *worldsTable;
  IBOutlet NSTableView *playersTable;
  
  IBOutlet NSArrayController *playersArrayController;
  IBOutlet NSArrayController *worldsArrayController;
  
  IBOutlet NSWindow *worldEditorSheet;
  IBOutlet NSTextField *worldNameField;
  IBOutlet NSTextField *worldHostnameField;
  IBOutlet NSTextField *worldPortField;
  IBOutlet NSTextField *worldURLField;
  IBOutlet NSButton *worldConnectOnAppLaunchButton;
  IBOutlet NSButton *worldUsesSSLButton;
  IBOutlet NSButton *worldUsesProxyButton;
  IBOutlet NSTextField *worldProxyHostnameField;
  IBOutlet NSTextField *worldProxyPortField;
  IBOutlet NSPopUpButton *worldProxyVersionButton;
  IBOutlet NSTextField *worldProxyUsernameField;
  IBOutlet NSSecureTextField *worldProxyPasswordField;
  IBOutlet NSButton *worldSaveButton;
  
  IBOutlet NSWindow *playerEditorSheet;
  IBOutlet NSTextField *playerNameField;
  IBOutlet NSSecureTextField *playerPasswordField;
  IBOutlet NSButton *playerConnectOnAppLaunchButton;
  IBOutlet NSButton *playerSaveButton;
}

- (IBAction) addPlayer:(id)sender;
- (IBAction) addWorld:(id)sender;
- (IBAction) editClickedPlayer:(id)sender;
- (IBAction) editClickedWorld:(id)sender;
- (IBAction) editPlayer:(id)sender;
- (IBAction) editWorld:(id)sender;
- (IBAction) endEditingPlayer:(id)sender;
- (IBAction) endEditingWorld:(id)sender;
- (IBAction) removePlayer:(id)sender;
- (IBAction) removeWorld:(id)sender;

@end

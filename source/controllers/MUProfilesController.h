//
// MUProfilesController.h
//
// Copyright (c) 2004, 2005 3James Software
//

#import <Cocoa/Cocoa.h>

@class MUWorldRegistry;

@interface MUProfilesController : NSWindowController
{
  IBOutlet NSOutlineView *worldsAndPlayersOutlineView;
	
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
- (IBAction) editClickedRow:(id)sender;
- (IBAction) editSelectedRow:(id)sender;
- (IBAction) endEditingPlayer:(id)sender;
- (IBAction) endEditingWorld:(id)sender;
- (IBAction) removeSelectedRow:(id)sender;

@end

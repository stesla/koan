//
// MUProfilesController.h
//
// Copyright (c) 2010 3James Software.
//

#import <Cocoa/Cocoa.h>

@class MUProfile;
@class MUWorldRegistry;

@interface MUProfilesController : NSWindowController
{
  IBOutlet NSOutlineView *worldsAndPlayersOutlineView;
  
  IBOutlet NSWindow *profileEditorSheet;
  IBOutlet NSButton *profileAutoconnectButton;
  IBOutlet NSTextField *profileFontField;
  IBOutlet NSButton *profileFontUseGlobalButton;
  IBOutlet NSColorWell *profileTextColorWell;
  IBOutlet NSButton *profileTextColorUseGlobalButton;
  IBOutlet NSColorWell *profileBackgroundColorWell;
  IBOutlet NSButton *profileBackgroundColorUseGlobalButton;
  IBOutlet NSColorWell *profileLinkColorWell;
  IBOutlet NSButton *profileLinkColorUseGlobalButton;
  IBOutlet NSColorWell *profileVisitedLinkColorWell;
  IBOutlet NSButton *profileVisitedLinkColorUseGlobalButton;
  IBOutlet NSButton *profileSaveButton;
  
  BOOL backgroundColorActive;
  BOOL linkColorActive;
  BOOL textColorActive;
  BOOL visitedLinkColorActive;
  
  MUProfile *editingProfile;
  NSFont *editingFont;
  
  IBOutlet NSWindow *worldEditorSheet;
  IBOutlet NSTextField *worldNameField;
  IBOutlet NSTextField *worldHostnameField;
  IBOutlet NSTextField *worldPortField;
  IBOutlet NSTextField *worldURLField;
  IBOutlet NSButton *worldSaveButton;
  
  IBOutlet NSWindow *playerEditorSheet;
  IBOutlet NSTextField *playerNameField;
  IBOutlet NSSecureTextField *playerPasswordField;
  IBOutlet NSButton *playerSaveButton;
}

- (IBAction) addPlayer: (id) sender;
- (IBAction) addWorld: (id) sender;
- (IBAction) chooseNewFont: (id) sender;
- (IBAction) editClickedRow: (id) sender;
- (IBAction) editProfileForSelectedRow: (id) sender;
- (IBAction) editSelectedRow: (id) sender;
- (IBAction) endEditingPlayer: (id) sender;
- (IBAction) endEditingProfile: (id) sender;
- (IBAction) endEditingWorld: (id) sender;
- (IBAction) goToWorldURL: (id) sender;
- (IBAction) removeSelectedRow: (id) sender;
- (IBAction) useGlobalBackgroundColor: (id) sender;
- (IBAction) useGlobalFont: (id) sender;
- (IBAction) useGlobalLinkColor: (id) sender;
- (IBAction) useGlobalTextColor: (id) sender;
- (IBAction) useGlobalVisitedLinkColor: (id) sender;

@end

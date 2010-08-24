//
// MUApplicationController.h
//
// Copyright (c) 2010 3James Software.
//

#import <Cocoa/Cocoa.h>

#import "CTBadge.h"
@class MUAcknowledgementsController;
@class MUPreferencesController;
@class MUProfilesController;
@class MUProxySettingsController;

@interface MUApplicationController : NSObject
{
  IBOutlet NSMenu *openConnectionMenu;
  
  IBOutlet NSPanel *newConnectionPanel;
  IBOutlet NSTextField *newConnectionHostnameField;
  IBOutlet NSTextField *newConnectionPortField;
  IBOutlet NSButton *newConnectionSaveWorldButton;
  
  IBOutlet MUPreferencesController *preferencesController;
  
  unsigned unreadCount;
  CTBadge *dockBadge;
  
  NSMutableArray *connectionWindowControllers;
  MUAcknowledgementsController *acknowledgementsController;
  MUProfilesController *profilesController;
  MUProxySettingsController *proxySettingsController;
}

- (IBAction) chooseNewFont: (id) sender;
- (IBAction) connectToURL: (NSURL *) url;
- (IBAction) connectUsingPanelInformation: (id) sender;
- (IBAction) openBugsWebPage: (id) sender;
- (IBAction) openNewConnectionPanel: (id) sender;
- (IBAction) showAboutPanel: (id) sender;
- (IBAction) showAcknowledgementsWindow: (id) sender;
- (IBAction) showPreferencesWindow: (id) sender;
- (IBAction) showProfilesPanel: (id) sender;
- (IBAction) showProxySettings: (id) sender;
- (IBAction) toggleUseProxy: (id) sender;

@end

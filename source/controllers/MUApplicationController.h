//
// MUApplicationController.h
//
// Copyright (c) 2004, 2005 3James Software
//

#import <Cocoa/Cocoa.h>

@class MUProfilesController;
@class MUUpdateController;

@interface MUApplicationController : NSObject
{
  IBOutlet NSMenu *openConnectionMenu;
	
  IBOutlet NSPanel *preferencesPanel;
	IBOutlet NSColorWell *globalTextColorWell;
	IBOutlet NSColorWell *globalBackgroundColorWell;
	IBOutlet NSColorWell *globalLinkColorWell;
	IBOutlet NSColorWell *globalVisitedLinkColorWell;
	
	IBOutlet NSPanel *newConnectionPanel;
	IBOutlet NSTextField *newConnectionHostnameField;
	IBOutlet NSTextField *newConnectionPortField;
	IBOutlet NSButton *newConnectionSaveWorldButton;
  
  IBOutlet MUUpdateController *updateController;
  
  unsigned unreadCount;
  
  NSMutableArray *connectionWindowControllers;
  MUProfilesController *profilesController;
}

- (IBAction) chooseNewFont:(id)sender;
- (IBAction) connectUsingPanelInformation:(id)sender;
- (IBAction) openBugsWebPage:(id)sender;
- (IBAction) openNewConnectionPanel:(id)sender;
- (IBAction) showPreferencesPanel:(id)sender;
- (IBAction) showProfilesPanel:(id)sender;

@end

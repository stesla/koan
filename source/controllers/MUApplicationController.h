//
// MUApplicationController.h
//
// Copyright (C) 2004, 2005 3James Software
//

#import <Cocoa/Cocoa.h>

@class MUProfilesController;

@interface MUApplicationController : NSObject
{
  IBOutlet NSPanel *preferencesPanel;
  IBOutlet NSMenu *openConnectionMenu;
  
  unsigned unreadCount;
  
  NSMutableArray *connectionWindowControllers;
  MUProfilesController *profilesController;
}

- (IBAction) changeGlobalFont:(id)sender;
- (IBAction) chooseNewFont:(id)sender;
- (IBAction) openBugsWebPage:(id)sender;
- (IBAction) showPreferences:(id)sender;
- (IBAction) showProfiles:(id)sender;

@end

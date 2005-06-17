//
// MUUpdateController.h
//
// Copyright (c) 2005 3James Software
//

#import <Cocoa/Cocoa.h>

@class MacPADSocket;

@interface MUUpdateController : NSObject
{
  IBOutlet NSTextField *currentVersionField;
  IBOutlet NSTextField *newestVersionField;
  IBOutlet NSTextField *lastCheckedField;
  IBOutlet NSPopUpButton *checkAutomaticallyIntervalButton;
  IBOutlet NSButton *checkAutomaticallyButton;
  IBOutlet NSButton *downloadButton;
  IBOutlet NSButton *checkNowButton;
  IBOutlet NSProgressIndicator *progressIndicator;
  
  MacPADSocket *macPADSocket;
  NSLock *updateLock;
  NSTimer *automaticCheckTimer;
  
  BOOL showDialogIfUpdateIsAvailable;
  BOOL showDialogIfUpdateIsNotAvailable;
  BOOL showDialogForErrors;
}

- (IBAction) checkForUpdates:(id)sender;
- (IBAction) checkForUpdatesWithDialog:(id)sender;
- (IBAction) download:(id)sender;
- (IBAction) toggleAutomaticChecking:(id)sender;

@end

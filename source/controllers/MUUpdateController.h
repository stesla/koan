//
// MUUpdateController.h
//
// Copyright (c) 2005 3James Software
//

#import <Cocoa/Cocoa.h>

@class MacPADSocket;

@interface MUUpdateController : NSObject
{
  IBOutlet NSTextField *urlField;
  IBOutlet NSTextField *versionField;
  IBOutlet NSTextField *codeText;
  IBOutlet NSTextField *msgText;
  IBOutlet NSTextField *versionText;
  IBOutlet NSTextField *productURLText;
  IBOutlet NSTextField *downloadURLText;
  IBOutlet NSTextView  *releaseNotesText;
  IBOutlet NSProgressIndicator *progressIndicator;
  
  MacPADSocket *macPAD;
}

- (IBAction) checkForUpdates:(id)sender;

@end

//
// MUProfilesController.h
//
// Copyright (c) 2010 3James Software.
//

#import <Cocoa/Cocoa.h>

@interface MUPreferencesController : NSObject
{
  IBOutlet NSWindow *preferencesWindow;
  IBOutlet NSColorWell *globalTextColorWell;
  IBOutlet NSColorWell *globalBackgroundColorWell;
  IBOutlet NSColorWell *globalLinkColorWell;
  IBOutlet NSColorWell *globalVisitedLinkColorWell;
}

- (IBAction) changeFont;
- (void) colorPanelColorDidChange;
- (void) playSelectedSound: (id) sender;
- (void) showPreferencesWindow: (id) sender;

@end

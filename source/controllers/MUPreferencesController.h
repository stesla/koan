//
// MUProfilesController.h
//
// Copyright (c) 2005 3James Software
//

#import <Cocoa/Cocoa.h>

@interface MUPreferencesController : NSObject
{
  IBOutlet NSPanel *preferencesPanel;
	IBOutlet NSColorWell *globalTextColorWell;
	IBOutlet NSColorWell *globalBackgroundColorWell;
	IBOutlet NSColorWell *globalLinkColorWell;
	IBOutlet NSColorWell *globalVisitedLinkColorWell;
	IBOutlet NSButton *playSoundsButton;
  IBOutlet NSButton *playWhenActiveButton;
  IBOutlet NSTextField *soundChoiceString;
  IBOutlet NSPopUpButton *soundChoiceButton;
}

- (IBAction) changeFont;
- (void) colorPanelColorDidChange;
- (void) showPreferencesPanel:(id)sender;

@end

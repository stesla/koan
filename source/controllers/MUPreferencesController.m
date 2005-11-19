//
// MUProfilesController.m
//
// Copyright (c) 2005 3James Software
//

#import "MUPreferencesController.h"

@interface MUPreferencesController (Private)

- (void) postGlobalBackgroundColorDidChangeNotification;
- (void) postGlobalFontDidChangeNotification;
- (void) postGlobalLinkColorDidChangeNotification;
- (void) postGlobalTextColorDidChangeNotification;
- (void) postGlobalVisitedLinkColorDidChangeNotification;

@end

#pragma mark -

@implementation MUPreferencesController

- (IBAction) changeFont
{
  NSFontManager *fontManager = [NSFontManager sharedFontManager];
  NSFont *selectedFont = [fontManager selectedFont];
  NSFont *panelFont;
  NSNumber *fontSize;
	id currentPrefsValues = [[NSUserDefaultsController sharedUserDefaultsController] values];
  
  if (selectedFont == nil)
  {
    selectedFont = [NSFont systemFontOfSize:[NSFont systemFontSize]];
  }
	
  panelFont = [fontManager convertFont:selectedFont];
  fontSize = [NSNumber numberWithFloat:[panelFont pointSize]];	
  
  [currentPrefsValues setValue:[panelFont fontName] forKey:MUPFontName];
  [currentPrefsValues setValue:fontSize forKey:MUPFontSize];
	
	[self postGlobalFontDidChangeNotification];
}

- (void) colorPanelColorDidChange
{
	if ([globalTextColorWell isActive])
		[self postGlobalTextColorDidChangeNotification];
	else if ([globalBackgroundColorWell isActive])
		[self postGlobalBackgroundColorDidChangeNotification];
	else if ([globalLinkColorWell isActive])
		[self postGlobalLinkColorDidChangeNotification];
	else if ([globalVisitedLinkColorWell isActive])
		[self postGlobalVisitedLinkColorDidChangeNotification];
}

- (void) showPreferencesPanel:(id)sender
{
  [preferencesPanel makeKeyAndOrderFront:self];
}

@end

#pragma mark -

@implementation MUPreferencesController (Private)

- (void) postGlobalBackgroundColorDidChangeNotification
{
	[[NSNotificationCenter defaultCenter] postNotificationName:MUGlobalBackgroundColorDidChangeNotification
																											object:self];
}

- (void) postGlobalFontDidChangeNotification
{
	[[NSNotificationCenter defaultCenter] postNotificationName:MUGlobalFontDidChangeNotification
																											object:self];
}

- (void) postGlobalLinkColorDidChangeNotification
{
	[[NSNotificationCenter defaultCenter] postNotificationName:MUGlobalLinkColorDidChangeNotification
																											object:self];
}

- (void) postGlobalTextColorDidChangeNotification
{
	[[NSNotificationCenter defaultCenter] postNotificationName:MUGlobalTextColorDidChangeNotification
																											object:self];
}

- (void) postGlobalVisitedLinkColorDidChangeNotification
{
	[[NSNotificationCenter defaultCenter] postNotificationName:MUGlobalVisitedLinkColorDidChangeNotification
																											object:self];
}

@end

//
// MUFontsColorsPaneController.m
//
// Copyright (C) 2004 Tyler Berry and Samuel Tesla
//
// Koan is free software; you can redistribute it and/or modify it under the
// terms of the GNU General Public License as published by the Free Software
// Foundation; either version 2 of the License, or (at your option) any later
// version.
//
// Koan is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// Koan; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
// Suite 330, Boston, MA 02111-1307 USA
//

#import "MUFontsColorsPaneController.h"
#import "FontNameToDisplayNameTransformer.h"
#import "MUConstants.h"

@implementation MUFontsColorsPaneController

+ (void) initialize
{
  NSValueTransformer *transformer = [[FontNameToDisplayNameTransformer alloc] init];
  [NSValueTransformer setValueTransformer:transformer forName:@"FontNameToDisplayNameTransformer"];
}

- (void)changeTextFont:(id)sender
{
  NSDictionary *values = [[NSUserDefaultsController sharedUserDefaultsController] values];
  NSString *fontName = [values valueForKey:@"MUPFontName"];
  float fontSize = [[values valueForKey:@"MUPFontSize"] floatValue];
  NSFont *font = [NSFont fontWithName:fontName size:fontSize];

  if (font == nil)
  {
    font = [NSFont userFixedPitchFontOfSize:[NSFont smallSystemFontSize]];
  }
  
  [[NSFontManager sharedFontManager] setSelectedFont:font isMultiple:NO];
  [[NSFontManager sharedFontManager] orderFrontFontPanel:self];
  
  [[paneView window] makeFirstResponder:[paneView window]];
}

- (void) changeFont:(id)sender
{
  NSFontManager *fontManager = [NSFontManager sharedFontManager];
  NSFont *selectedFont = [fontManager selectedFont];
  NSFont *panelFont;
  NSNumber *fontSize;
  id currentPrefsValues;
  
  if (selectedFont == nil)
  {
    selectedFont = [NSFont userFixedPitchFontOfSize:[NSFont smallSystemFontSize]];
  }
  
  panelFont = [fontManager convertFont:selectedFont];
  
  // Get and store details of selected font
  // Note: use fontName, not displayName.  The font name identifies the font to
  // the system, we use a value transformer to show the user the display name
  fontSize = [NSNumber numberWithFloat:[panelFont pointSize]];	
  
  currentPrefsValues = [[NSUserDefaultsController sharedUserDefaultsController] values];
  [currentPrefsValues setValue:[panelFont fontName] forKey:@"MUPFontName"];
  [currentPrefsValues setValue:fontSize forKey:@"MUPFontSize"];
}

// Implementation of the SSPreferencePaneProtocol protocol.

+ (NSArray *) preferencePanes
{
  return [NSArray arrayWithObjects:[[[MUFontsColorsPaneController alloc] init] autorelease], nil];
}

- (NSView *) paneView
{
  BOOL loaded = YES;
  
  if (!paneView)
  {
    loaded = [NSBundle loadNibNamed:@"MUFontsColorsPane" owner:self];
  }
  
  if (loaded)
  {
    return paneView;
  }
  
  return nil;
}

- (NSString *) paneName
{
  return NSLocalizedString (MULPreferencePaneFontsColorsName, nil);
}

- (NSImage *) paneIcon
{
  return nil;
}

- (NSString *) paneToolTip
{
  return NSLocalizedString (MULPreferencePaneFontsColorsToolTip, nil);
}

- (BOOL) allowsHorizontalResizing
{
  return NO;
}

- (BOOL) allowsVerticalResizing
{
  return NO;
}

@end
//
// MUApplicationController.m
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

#import "MUApplicationController.h"

@implementation MUApplicationController

+ (void) initialize
{
  NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
  NSData *archivedWhite = [NSArchiver archivedDataWithRootObject:[NSColor lightGrayColor]];
  NSData *archivedBlack = [NSArchiver archivedDataWithRootObject:[NSColor blackColor]];
  NSFont *fixedFont = [NSFont userFixedPitchFontOfSize:[NSFont smallSystemFontSize]];
  
  [defaults setObject:[fixedFont fontName] forKey:MUPFontName];
  [defaults setObject:[NSNumber numberWithFloat:[fixedFont pointSize]] forKey:MUPFontSize];
  [defaults setObject:archivedBlack forKey:MUPBackgroundColor];
  [defaults setObject:archivedWhite forKey:MUPTextColor];
  
  [[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:defaults];
}

- (IBAction) showPreferences:(id)sender
{
  if (!_prefsController)
  {    
    _prefsController = [[SSPrefsController alloc] init];
    
    [_prefsController setPanesOrder:[NSArray arrayWithObjects:
      NSLocalizedString (MULPreferencePaneConnectionsName, nil),
      NSLocalizedString (MULPreferencePaneLoggingName, nil),
      nil]];
  }
  
  [_prefsController showPreferencesWindow];
}

@end
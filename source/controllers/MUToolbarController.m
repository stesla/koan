//
// MUToolbarController.m
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

#import "MUToolbarController.h"

@implementation MUToolbarController

- (void) awakeFromNib
{
  _toolbar = [[NSToolbar alloc] initWithIdentifier:@"mainWindowToolbar"];
  [_toolbar setDelegate:self];
  [_toolbar setAllowsUserCustomization:YES];
  [_toolbar setAutosavesConfiguration:YES];
  
  [window setToolbar:[_toolbar autorelease]];
}

// Implementation of NSToolbar delegate methods.

- (NSToolbarItem *) toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag
{
  NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
  
  if ([itemIdentifier isEqualToString:MUTSearchItemIdentifier])
  {
    NSRect fRect = [searchItemView frame];
    
    [item setLabel:@"Search"];
    [item setPaletteLabel:[item label]];
    [item setView:searchItemView];
    [item setMinSize:fRect.size];
    [item setMaxSize:fRect.size];
  }
  
  return [item autorelease];
}

- (NSArray *) toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar
{
  return [NSArray arrayWithObjects:
    NSToolbarFlexibleSpaceItemIdentifier,
    MUTSearchItemIdentifier,
    NSToolbarCustomizeToolbarItemIdentifier,
    nil];
}

- (NSArray *) toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar
{
  return [NSArray arrayWithObjects:
    NSToolbarSeparatorItemIdentifier,
    NSToolbarSpaceItemIdentifier,
    NSToolbarFlexibleSpaceItemIdentifier,
    NSToolbarCustomizeToolbarItemIdentifier,
    NSToolbarShowColorsItemIdentifier,
    NSToolbarShowFontsItemIdentifier,
    MUTSearchItemIdentifier,
    NSToolbarPrintItemIdentifier,
    nil];
}

@end
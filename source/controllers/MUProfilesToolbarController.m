//
// MUProfilesToolbarController.m
//
// Copyright (c) 2004, 2005 3James Software
//

#import "MUProfilesToolbarController.h"

@implementation MUProfilesToolbarController

- (void) awakeFromNib
{
  toolbar = [[NSToolbar alloc] initWithIdentifier:@"profilesWindowToolbar"];
  [toolbar setDelegate:self];
  [toolbar setAllowsUserCustomization:YES];
  [toolbar setAutosavesConfiguration:YES];
  
  [window setToolbar:toolbar];
	[toolbar release];
}

#pragma mark -
#pragma mark NSToolbar delegate

- (NSToolbarItem *) toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag
{
  NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
  
	if ([itemIdentifier isEqualToString:MUAddWorldToolbarItem])
	{
		[item setLabel:NSLocalizedString (MULAddWorld, nil)];
		[item setPaletteLabel:NSLocalizedString (MULAddWorld, nil)];
		[item setImage:nil];
		[item setTarget:windowController];
		[item setAction:@selector(addWorld:)];
	}
	else if ([itemIdentifier isEqualToString:MUAddPlayerToolbarItem])
	{
		[item setLabel:NSLocalizedString (MULAddPlayer, nil)];
		[item setPaletteLabel:NSLocalizedString (MULAddPlayer, nil)];
		[item setImage:nil];
		[item setTarget:windowController];
		[item setAction:@selector(addPlayer:)];
	}
	else if ([itemIdentifier isEqualToString:MUEditSelectedRowToolbarItem])
	{
		[item setLabel:NSLocalizedString (MULEditItem, nil)];
		[item setPaletteLabel:NSLocalizedString (MULEditItem, nil)];
		[item setImage:nil];
		[item setTarget:windowController];
		[item setAction:@selector(editSelectedRow:)];
	}
	else if ([itemIdentifier isEqualToString:MURemoveSelectedRowToolbarItem])
	{
		[item setLabel:NSLocalizedString (MULRemoveItem, nil)];
		[item setPaletteLabel:NSLocalizedString (MULRemoveItem, nil)];
		[item setImage:nil];
		[item setTarget:windowController];
		[item setAction:@selector(removeSelectedRow:)];
	}
	else if ([itemIdentifier isEqualToString:MUEditProfileForSelectedRowToolbarItem])
	{
		[item setLabel:NSLocalizedString (MULEditProfile, nil)];
		[item setPaletteLabel:NSLocalizedString (MULEditProfile, nil)];
		[item setImage:nil];
		[item setTarget:windowController];
		[item setAction:@selector(editProfileForSelectedRow:)];
	}
  else if ([itemIdentifier isEqualToString:MUGoToURLToolbarItem])
  {
    [item setLabel:NSLocalizedString (MULGoToURL, nil)];
    [item setPaletteLabel:NSLocalizedString (MULGoToURL, nil)];
    [item setImage:nil];
    [item setTarget:windowController];
    [item setAction:@selector(goToWorldURL:)];
  }
	
  return [item autorelease];
}

- (NSArray *) toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar
{
  return [NSArray arrayWithObjects:
		MUAddWorldToolbarItem,
		MUAddPlayerToolbarItem,
		MUEditSelectedRowToolbarItem,
		MURemoveSelectedRowToolbarItem,
    NSToolbarFlexibleSpaceItemIdentifier,
    NSToolbarCustomizeToolbarItemIdentifier,
		MUEditProfileForSelectedRowToolbarItem,
    nil];
}

- (NSArray *) toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar
{
  return [NSArray arrayWithObjects:
    NSToolbarSeparatorItemIdentifier,
    NSToolbarSpaceItemIdentifier,
    NSToolbarFlexibleSpaceItemIdentifier,
    NSToolbarCustomizeToolbarItemIdentifier,
		MUAddWorldToolbarItem,
		MUAddPlayerToolbarItem,
		MUEditSelectedRowToolbarItem,
		MURemoveSelectedRowToolbarItem,
		MUEditProfileForSelectedRowToolbarItem,
    MUGoToURLToolbarItem,
    nil];
}

@end

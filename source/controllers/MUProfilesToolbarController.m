//
// MUProfilesToolbarController.m
//
// Copyright (c) 2010 3James Software.
//

#import "MUProfilesToolbarController.h"

@implementation MUProfilesToolbarController

- (void) awakeFromNib
{
  toolbar = [[NSToolbar alloc] initWithIdentifier: @"profilesWindowToolbar"];
  [toolbar setDelegate: self];
  [toolbar setAllowsUserCustomization: YES];
  [toolbar setAutosavesConfiguration: YES];
  
  [window setToolbar: toolbar];
  [toolbar release];
}

#pragma mark -
#pragma mark NSToolbar delegate

- (NSToolbarItem *) toolbar: (NSToolbar *) toolbar itemForItemIdentifier: (NSString *) itemIdentifier willBeInsertedIntoToolbar: (BOOL) flag
{
  NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier: itemIdentifier];
  
  if ([itemIdentifier isEqualToString: MUAddWorldToolbarItem])
  {
  	[item setLabel: _(MULAddWorld)];
  	[item setPaletteLabel: _(MULAddWorld)];
  	[item setImage: nil];
  	[item setTarget: windowController];
  	[item setAction: @selector (addWorld:)];
  }
  else if ([itemIdentifier isEqualToString: MUAddPlayerToolbarItem])
  {
  	[item setLabel: _(MULAddPlayer)];
  	[item setPaletteLabel: _(MULAddPlayer)];
  	[item setImage: nil];
  	[item setTarget: windowController];
  	[item setAction: @selector (addPlayer:)];
  }
  else if ([itemIdentifier isEqualToString: MUEditSelectedRowToolbarItem])
  {
  	[item setLabel: _(MULEditItem)];
  	[item setPaletteLabel: _(MULEditItem)];
  	[item setImage: nil];
  	[item setTarget: windowController];
  	[item setAction: @selector (editSelectedRow:)];
  }
  else if ([itemIdentifier isEqualToString: MURemoveSelectedRowToolbarItem])
  {
  	[item setLabel: _(MULRemoveItem)];
  	[item setPaletteLabel: _(MULRemoveItem)];
  	[item setImage: nil];
  	[item setTarget: windowController];
  	[item setAction: @selector (removeSelectedRow:)];
  }
  else if ([itemIdentifier isEqualToString: MUEditProfileForSelectedRowToolbarItem])
  {
  	[item setLabel: _(MULEditProfile)];
  	[item setPaletteLabel: _(MULEditProfile)];
  	[item setImage: nil];
  	[item setTarget: windowController];
  	[item setAction: @selector (editProfileForSelectedRow:)];
  }
  else if ([itemIdentifier isEqualToString: MUGoToURLToolbarItem])
  {
    [item setLabel: _(MULGoToURL)];
    [item setPaletteLabel: _(MULGoToURL)];
    [item setImage: nil];
    [item setTarget: windowController];
    [item setAction: @selector (goToWorldURL:)];
  }
  
  return [item autorelease];
}

- (NSArray *) toolbarDefaultItemIdentifiers: (NSToolbar*) toolbar
{
  return [NSArray arrayWithObjects:
  	MUAddWorldToolbarItem,
  	MUAddPlayerToolbarItem,
  	MUEditSelectedRowToolbarItem,
  	MURemoveSelectedRowToolbarItem,
  	MUEditProfileForSelectedRowToolbarItem,
    NSToolbarFlexibleSpaceItemIdentifier,
    NSToolbarCustomizeToolbarItemIdentifier,
    nil];
}

- (NSArray *) toolbarAllowedItemIdentifiers: (NSToolbar*) toolbar
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

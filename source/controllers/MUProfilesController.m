//
// MUProfilesController.m
//
// Copyright (c) 2004, 2005 3James Software
//

#import <J3Terminal/J3ProxySettings.h>
#import "MUProfilesController.h"
#import "J3PortFormatter.h"
#import "MUProfile.h"
#import "MUServices.h"

enum MUProfilesEditingReturnValues
{
  MUEditOkay,
  MUEditCancel
};

@interface MUProfilesController (Private)

- (MUWorld *) createWorldFromSheetWithPlayers:(NSArray *)players;
- (IBAction) editPlayer:(MUPlayer *)player;
- (IBAction) editProfile:(MUProfile *)player;
- (IBAction) editWorld:(MUWorld *)world;
- (void) playerSheetDidEndAdding:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;
- (void) playerSheetDidEndEditing:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;
- (void) profileSheetDidEndEditing:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;
- (IBAction) removePlayer:(MUPlayer *)player;
- (IBAction) removeWorld:(MUWorld *)world;
- (void) updateProfilesForWorld:(MUWorld *)world withWorld:(MUWorld *)newWorld;
- (void) updateProfileForWorld:(MUWorld *)world 
                        player:(MUPlayer *)player 
                    withPlayer:(MUPlayer *)newPlayer;
- (void) worldSheetDidEndAdding:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;
- (void) worldSheetDidEndEditing:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;

@end

#pragma mark -

@implementation MUProfilesController

- (id) init
{
  return [super initWithWindowNibName:@"MUProfiles"];
}

- (void) awakeFromNib
{
  J3PortFormatter *worldPortFormatter = [[[J3PortFormatter alloc] init] autorelease];
  J3PortFormatter *proxyPortFormatter = [[[J3PortFormatter alloc] init] autorelease];
  
  [worldPortField setFormatter:worldPortFormatter];
  [worldProxyPortField setFormatter:proxyPortFormatter];
  
	[worldsAndPlayersOutlineView setAutosaveExpandedItems:YES];
  [worldsAndPlayersOutlineView setTarget:self];
  [worldsAndPlayersOutlineView setDoubleAction:@selector(editClickedRow:)];
}

- (BOOL)validateToolbarItem:(NSToolbarItem *)toolbarItem
{
	SEL toolbarItemAction = [toolbarItem action];
	
	if (toolbarItemAction == @selector(addWorld:))
	{
		return YES;
	}
	else if (toolbarItemAction == @selector(addPlayer:) ||
					 toolbarItemAction == @selector(editProfileForSelectedRow:))
	{
		if ([worldsAndPlayersOutlineView numberOfSelectedRows] == 0)
			return NO;
		else
			return YES;
	}
	else if (toolbarItemAction == @selector(editSelectedRow:))
	{
		if ([worldsAndPlayersOutlineView numberOfSelectedRows] == 0)
		{
			[toolbarItem setLabel:NSLocalizedString (MULEditItem, nil)];
			return NO;
		}
		else
		{
			id item = [worldsAndPlayersOutlineView itemAtRow:[worldsAndPlayersOutlineView selectedRow]];
			
			if ([item isKindOfClass:[MUWorld class]])
				[toolbarItem setLabel:NSLocalizedString (MULEditWorld, nil)];
			else
				[toolbarItem setLabel:NSLocalizedString (MULEditPlayer, nil)];
			
			return YES;
		}
	}
	else if (toolbarItemAction == @selector(removeSelectedRow:))
	{
		if ([worldsAndPlayersOutlineView numberOfSelectedRows] == 0)
		{
			[toolbarItem setLabel:NSLocalizedString (MULRemoveItem, nil)];
			return NO;
		}
		else
		{
			id item = [worldsAndPlayersOutlineView itemAtRow:[worldsAndPlayersOutlineView selectedRow]];
			
			if ([item isKindOfClass:[MUWorld class]])
				[toolbarItem setLabel:NSLocalizedString (MULRemoveWorld, nil)];
			else
				[toolbarItem setLabel:NSLocalizedString (MULRemovePlayer, nil)];
			
			return YES;
		}
	}
	
	return NO;
}

#pragma mark -
#pragma mark Actions

- (IBAction) addPlayer:(id)sender
{
	int selectedRow = [worldsAndPlayersOutlineView selectedRow];
	MUWorld *insertionWorld;
	int insertionIndex;
	NSDictionary *contextDictionary;
	
  [playerNameField setStringValue:@""];
  [playerPasswordField setStringValue:@""];
  [playerConnectOnAppLaunchButton setState:NSOffState];
  
  [playerEditorSheet makeFirstResponder:playerNameField];
  
	if (selectedRow == -1)
		return;
	else
	{
		id selectedItem;
		
		selectedItem = [worldsAndPlayersOutlineView itemAtRow:selectedRow];
		
		if ([selectedItem isKindOfClass:[MUWorld class]])
		{
			insertionWorld = (MUWorld *) selectedItem;
			insertionIndex = [[insertionWorld players] count];
		}
		else if ([selectedItem isKindOfClass:[MUPlayer class]])
		{
			MUPlayer *selectedPlayer = (MUPlayer *) selectedItem;
			int index = [[selectedPlayer world] indexOfPlayer:selectedPlayer] + 1;
			
			if (index < 0)
				return;
			
			insertionIndex = (unsigned) index;
			insertionWorld = [selectedPlayer world];
		}
		else
			return;
	}
	
	contextDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
		[NSNumber numberWithUnsignedInt:insertionIndex], MUInsertionIndex,
		insertionWorld, MUInsertionWorld,
		NULL];
	
  [NSApp beginSheet:playerEditorSheet
     modalForWindow:[self window]
      modalDelegate:self
     didEndSelector:@selector(playerSheetDidEndAdding:returnCode:contextInfo:)
        contextInfo:contextDictionary];
}

- (IBAction) addWorld:(id)sender
{
	int selectedRow = [worldsAndPlayersOutlineView selectedRow];
	int insertionIndex;
	
  [worldNameField setStringValue:@""];
  [worldHostnameField setStringValue:@""];
  [worldPortField setStringValue:@""];
  [worldURLField setStringValue:@""];
  [worldConnectOnAppLaunchButton setState:NSOffState];
  [worldUsesSSLButton setState:NSOffState];
  [worldUsesProxyButton setState:NSOffState];
  [worldProxyHostnameField setStringValue:@""];
  [worldProxyPortField setStringValue:@""];
  [worldProxyVersionButton selectItemAtIndex:1];
  [worldProxyUsernameField setStringValue:@""];
  [worldProxyPasswordField setStringValue:@""];
  
  [worldEditorSheet makeFirstResponder:worldNameField];
  
	if (selectedRow == -1)
		insertionIndex = [[MUServices worldRegistry] count];
	else
	{
		id selectedItem;
		MUWorld *selectedWorld;
		
		selectedItem = [worldsAndPlayersOutlineView itemAtRow:selectedRow];
		
		if ([selectedItem isKindOfClass:[MUWorld class]])
			selectedWorld = (MUWorld *) selectedItem;
		else if ([selectedItem isKindOfClass:[MUPlayer class]])
			selectedWorld = [(MUPlayer *) selectedItem world];
		
		insertionIndex = [[MUServices worldRegistry] indexOfWorld:selectedWorld] + 1;
	}
	
  [NSApp beginSheet:worldEditorSheet
     modalForWindow:[self window]
      modalDelegate:self
     didEndSelector:@selector(worldSheetDidEndAdding:returnCode:contextInfo:)
        contextInfo:[[NSNumber alloc] initWithUnsignedInt:insertionIndex]];
}

- (IBAction) editClickedRow:(id)sender
{
  NSEvent *event = [NSApp currentEvent];
  NSPoint location = [worldsAndPlayersOutlineView convertPoint:[event locationInWindow] fromView:nil];
  int row = [worldsAndPlayersOutlineView rowAtPoint:location];
	id clickedItem;
	
  if (row == -1)
    return;
	
	clickedItem = [worldsAndPlayersOutlineView itemAtRow:row];
		
	if ([clickedItem isKindOfClass:[MUWorld class]])
		[self editWorld:clickedItem];
	else if ([clickedItem isKindOfClass:[MUPlayer class]])
		[self editPlayer:clickedItem];
}

- (IBAction) editProfileForSelectedRow:(id)sender
{
	int selectedRow = [worldsAndPlayersOutlineView selectedRow];
	id selectedItem;
	
	if (selectedRow == -1)
		return;
	
	selectedItem = [worldsAndPlayersOutlineView itemAtRow:selectedRow];
	
	if ([selectedItem isKindOfClass:[MUWorld class]])
		[self editProfile:[[MUProfileRegistry sharedRegistry] profileForWorld:selectedItem]];
	else if ([selectedItem isKindOfClass:[MUPlayer class]])
		[self editProfile:[[MUProfileRegistry sharedRegistry] profileForWorld:[(MUPlayer *) selectedItem world]
																																	 player:selectedItem]];
}

- (IBAction) editSelectedRow:(id)sender
{
	int selectedRow = [worldsAndPlayersOutlineView selectedRow];
	id selectedItem;
	
	if (selectedRow == -1)
		return;
	
	selectedItem = [worldsAndPlayersOutlineView itemAtRow:selectedRow];
	
	if ([selectedItem isKindOfClass:[MUWorld class]])
		[self editWorld:selectedItem];
	else if ([selectedItem isKindOfClass:[MUPlayer class]])
		[self editPlayer:selectedItem];
}

- (IBAction) endEditingPlayer:(id)sender
{
  [playerEditorSheet orderOut:sender];
  [NSApp endSheet:playerEditorSheet returnCode:(sender == playerSaveButton ? MUEditOkay : MUEditCancel)];
}

- (IBAction) endEditingProfile:(id)sender
{
  [profileEditorSheet orderOut:sender];
  [NSApp endSheet:profileEditorSheet returnCode:(sender == profileSaveButton ? MUEditOkay : MUEditCancel)];
}

- (IBAction) endEditingWorld:(id)sender
{
  [worldEditorSheet orderOut:sender];
  [NSApp endSheet:worldEditorSheet returnCode:(sender == worldSaveButton ? MUEditOkay : MUEditCancel)];
}

- (IBAction) removeSelectedRow:(id)sender
{
	int selectedRow = [worldsAndPlayersOutlineView selectedRow];
	id selectedItem;
	
	if (selectedRow == -1)
		return;
	
	selectedItem = [worldsAndPlayersOutlineView itemAtRow:selectedRow];
	
	if ([selectedItem isKindOfClass:[MUWorld class]])
		[self removeWorld:selectedItem];
	else if ([selectedItem isKindOfClass:[MUPlayer class]])
		[self removePlayer:selectedItem];
}

#pragma mark -
#pragma mark NSOutlineView data source

- (id) outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item
{
	if (item)
		return [[(MUWorld *) item players] objectAtIndex:index];
	else
		return [[MUServices worldRegistry] worldAtIndex:index];
}

- (BOOL) outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
	if ([item isKindOfClass:[MUWorld class]])
		return YES;
	else
		return NO;
}

- (id) outlineView:(NSOutlineView *)outlineView itemForPersistentObject:(id)object
{
	if (object && [object isKindOfClass:[NSString class]])
	{
		return [[MUServices worldRegistry] worldForUniqueIdentifier:(NSString *) object];
	}
	
	return nil;
}

- (int) outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
	if (item)
		return [[(MUWorld *) item players] count];
	else
		return [[MUServices worldRegistry] count];
}

- (id) outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)column byItem:(id)item
{
	if ([item isKindOfClass:[MUWorld class]])
		return [(MUWorld *) item worldName];
	else if ([item isKindOfClass:[MUPlayer class]])
		return [(MUPlayer *) item name];
	else
		return item;
}

- (id) outlineView:(NSOutlineView *)outlineView persistentObjectForItem:(id)item
{
	if ([item isKindOfClass:[MUWorld class]])
		return [(MUWorld *) item uniqueIdentifier];
	else
		return nil;
}

#pragma mark -
#pragma mark NSOutlineView delegate

- (BOOL) outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
	return NO;
}

@end

#pragma mark -

@implementation MUProfilesController (Private)

- (IBAction) changeConnectionFont:(id)sender
{
  NSFontManager *fontManager = [NSFontManager sharedFontManager];
  NSFont *selectedFont = [fontManager selectedFont];
  NSFont *panelFont;
  
  if (selectedFont == nil)
  {
    selectedFont = [NSFont systemFontOfSize:[NSFont systemFontSize]];
  }
	
  panelFont = [fontManager convertFont:selectedFont];
  
  [editingProfile setValue:[panelFont fontName] forKey:@"fontName"];
  [editingProfile setValue:[NSNumber numberWithFloat:[panelFont pointSize]] forKey:@"fontSize"];
}

- (MUWorld *) createWorldFromSheetWithPlayers:(NSArray *)players
{
  J3ProxySettings *settings = nil;
  
  if ([worldUsesProxyButton state] == NSOnState)
  {
    settings = [J3ProxySettings 
        settingsWithHostname:[worldProxyHostnameField stringValue]
                        port:[worldProxyPortField intValue]
                     version:([worldProxyVersionButton indexOfSelectedItem] == 0 ? 4 : 5)
                    username:[worldProxyUsernameField stringValue]
                    password:[worldProxyPasswordField stringValue]];
  }
  
  return [[MUWorld alloc] initWithWorldName:[worldNameField stringValue]
                              worldHostname:[worldHostnameField stringValue]
                                  worldPort:[NSNumber numberWithInt:[worldPortField intValue]]
                                   worldURL:[worldURLField stringValue]
                                    usesSSL:([worldUsesSSLButton state] == NSOnState ? YES : NO)
                              proxySettings:settings
                                    players:players];
}

- (IBAction) editPlayer:(MUPlayer *)player
{
  MUWorld *world = [player world];
  
  [playerNameField setStringValue:[player name]];
  [playerPasswordField setStringValue:[player password]];
  [playerConnectOnAppLaunchButton setState:
    ([[[MUServices profileRegistry] profileForWorld:world
																						 player:player] autoconnect]
     ? NSOnState : NSOffState)];
  
  [playerEditorSheet makeFirstResponder:playerNameField];
  
  [NSApp beginSheet:playerEditorSheet
     modalForWindow:[self window]
      modalDelegate:self
     didEndSelector:@selector(playerSheetDidEndEditing:returnCode:contextInfo:)
        contextInfo:player];
}

- (IBAction) editProfile:(MUProfile *)profile
{
	editingProfile = [profile retain];
	
	[profileAutoconnectButton setState:([profile autoconnect] ? NSOnState : NSOffState)];
	[profileFontField setStringValue:[profile effectiveFontDisplayName]];
	[profileFontUseGlobalButton setState:([profile font] == nil ? NSOnState : NSOffState)];
	[profileTextColorWell setColor:[NSUnarchiver unarchiveObjectWithData:[profile effectiveTextColor]]];
	[profileTextColorUseGlobalButton setState:([profile textColor] == nil ? NSOnState : NSOffState)];
	[profileBackgroundColorWell setColor:[NSUnarchiver unarchiveObjectWithData:[profile effectiveBackgroundColor]]];
	[profileBackgroundColorUseGlobalButton setState:([profile backgroundColor] == nil ? NSOnState : NSOffState)];
	[profileLinkColorWell setColor:[NSUnarchiver unarchiveObjectWithData:[profile effectiveLinkColor]]];
	[profileLinkColorUseGlobalButton setState:([profile linkColor] == nil ? NSOnState : NSOffState)];
	[profileVisitedLinkColorWell setColor:[NSUnarchiver unarchiveObjectWithData:[profile effectiveVisitedLinkColor]]];
	[profileVisitedLinkColorUseGlobalButton setState:([profile visitedLinkColor] == nil ? NSOnState : NSOffState)];
	
	[NSApp beginSheet:profileEditorSheet
     modalForWindow:[self window]
      modalDelegate:self
     didEndSelector:@selector(profileSheetDidEndEditing:returnCode:contextInfo:)
        contextInfo:profile];
}

- (IBAction) editWorld:(MUWorld *)world
{
  J3ProxySettings *settings = [world proxySettings];
	
  [worldNameField setStringValue:[world worldName]];
  [worldHostnameField setStringValue:[world worldHostname]];
  [worldPortField setObjectValue:[world worldPort]];
  [worldURLField setStringValue:[world worldURL]];
  [worldUsesSSLButton setState:([world usesSSL] ? NSOnState : NSOffState)];
  [worldConnectOnAppLaunchButton setState:
    ([[[MUServices profileRegistry] profileForWorld:world] autoconnect]
     ? NSOnState : NSOffState)];
  
  if (settings)
  {
    [worldUsesProxyButton setState:NSOnState];
    [worldProxyHostnameField setStringValue:[settings hostname]];
    [worldProxyPortField setIntValue:[settings port]];
    [worldProxyVersionButton selectItemAtIndex:([settings version] == 4 ? 0 : 1)];
    [worldProxyUsernameField setStringValue:[settings username]];
    [worldProxyPasswordField setStringValue:[settings password]];
  }
  else
  {
    [worldUsesProxyButton setState:NSOffState];
    [worldProxyHostnameField setStringValue:@""];
    [worldProxyPortField setStringValue:@""];
    [worldProxyVersionButton selectItemAtIndex:1];
    [worldProxyUsernameField setStringValue:@""];
    [worldProxyPasswordField setStringValue:@""];
  }
  
  [worldEditorSheet makeFirstResponder:worldNameField];
  
  [NSApp beginSheet:worldEditorSheet
     modalForWindow:[self window]
      modalDelegate:self
     didEndSelector:@selector(worldSheetDidEndEditing:returnCode:contextInfo:)
        contextInfo:world];
}

- (void) playerSheetDidEndAdding:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
  if (returnCode == MUEditOkay)
  {
		NSDictionary *contextDictionary = (NSDictionary *) contextInfo;
		unsigned insertionIndex = [(NSNumber *) [contextDictionary objectForKey:MUInsertionIndex] unsignedIntValue];
		MUWorld *insertionWorld = (MUWorld *) [contextDictionary objectForKey:MUInsertionWorld];
    MUPlayer *newPlayer = [[MUPlayer alloc] initWithName:[playerNameField stringValue]
                                                password:[playerPasswordField stringValue]
                                                   world:insertionWorld];
    
    [[[MUServices profileRegistry] profileForWorld:insertionWorld
																						player:newPlayer]
      setAutoconnect:([playerConnectOnAppLaunchButton state] == NSOnState)];
    
		[insertionWorld insertObject:newPlayer inPlayersAtIndex:insertionIndex];
		
    [newPlayer release];
		[worldsAndPlayersOutlineView reloadData];
  }
	
	[(NSObject *) contextInfo release];
}

- (void) playerSheetDidEndEditing:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
  if (returnCode == MUEditOkay)
  {
		MUPlayer *oldPlayer = (MUPlayer *) contextInfo;
    MUWorld *oldWorld = [oldPlayer world];
    MUPlayer *newPlayer = [[MUPlayer alloc] initWithName:[playerNameField stringValue]
																								password:[playerPasswordField stringValue]
																									 world:oldWorld];
		
    // Updates the profile for the player/world with the new player object.
    [self updateProfileForWorld:oldWorld
                         player:oldPlayer
                     withPlayer:newPlayer];
		
		// Actually replace the old player with the new one.
		[oldWorld replacePlayer:oldPlayer withPlayer:newPlayer];
    
		// Change the autoconnect setting on the corresponding profile.
    [[[MUServices profileRegistry] profileForWorld:oldWorld player:newPlayer]
      setAutoconnect:([playerConnectOnAppLaunchButton state] == NSOnState)];
		
    [newPlayer release];
		[worldsAndPlayersOutlineView reloadData];
  }
}

- (void) profileSheetDidEndEditing:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	[editingProfile release];
	editingProfile = nil;
	
  if (returnCode == MUEditOkay)
  {
		MUProfile *oldProfile = (MUProfile *) contextInfo;
  }
}

- (IBAction) removePlayer:(MUPlayer *)player
{
  [[MUServices profileRegistry] removeProfileForWorld:[player world]
																							 player:player];
	[[player world] removePlayer:player];
	
	[worldsAndPlayersOutlineView reloadData];
}

- (IBAction) removeWorld:(MUWorld *)world
{
  [[MUServices profileRegistry] removeAllProfilesForWorld:world];
	[[MUServices worldRegistry] removeWorld:world];
	
	[worldsAndPlayersOutlineView reloadData];
}

- (void) updateProfilesForWorld:(MUWorld *)world 
                      withWorld:(MUWorld *)newWorld
{
  MUProfile *profile = nil;
  MUProfileRegistry *registry = [MUServices profileRegistry];
  NSArray *players = [world players];
  int i, count = [players count];
  
  for (i = 0; i < count; i++)
  {
    MUPlayer *player = [players objectAtIndex:i];
    profile = [registry profileForWorld:world
                                 player:player];
    [profile retain];
    [registry removeProfile:profile];
    [profile setWorld:newWorld];
    [player setWorld:newWorld];
    [registry profileForProfile:profile];
    [profile release];
  }
	
  profile = [registry profileForWorld:world];
  [profile retain];
  [registry removeProfile:profile];
  [profile setWorld:newWorld];
  [registry profileForProfile:profile];
  [profile release];
}

- (void) updateProfileForWorld:(MUWorld *)world 
                        player:(MUPlayer *)player 
                    withPlayer:(MUPlayer *)newPlayer
{
  MUProfileRegistry *registry = [MUServices profileRegistry];
  MUProfile *profile = [registry profileForWorld:world
                                          player:player];
  [profile retain];
  [registry removeProfile:profile];
  [profile setPlayer:newPlayer];
  [registry profileForProfile:profile];
  [profile release];
}

- (void) worldSheetDidEndAdding:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
  if (returnCode == MUEditOkay)
  {
    MUWorld *newWorld = [self createWorldFromSheetWithPlayers:[NSArray array]];
		unsigned insertionIndex = [(NSNumber *) contextInfo unsignedIntValue];
    
    [[[MUServices profileRegistry] profileForWorld:newWorld]
      setAutoconnect:([worldConnectOnAppLaunchButton state] == NSOnState)];
		
		[[MUServices worldRegistry] insertObject:newWorld inWorldsAtIndex:insertionIndex];
		
		[newWorld release];
		
		[worldsAndPlayersOutlineView reloadData];
		[worldsAndPlayersOutlineView expandItem:newWorld];
  }
	
	[(NSObject *) contextInfo release];
}

- (void) worldSheetDidEndEditing:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
  if (returnCode == MUEditOkay)
  {
    MUWorld *oldWorld = (MUWorld *) contextInfo;
    MUWorld *newWorld = [self createWorldFromSheetWithPlayers:[oldWorld players]];
		BOOL isExpanded = [worldsAndPlayersOutlineView isItemExpanded:oldWorld];
		
    // Update every profile that has this world.
    [self updateProfilesForWorld:oldWorld
                       withWorld:newWorld];
		
		// Actually replace the old world with the new one.
		[[MUServices worldRegistry] replaceWorld:oldWorld withWorld:newWorld];
    
    // Change the autoconnect setting on the profile for the world alone.
    [[[MUServices profileRegistry] profileForWorld:oldWorld]
      setAutoconnect:([worldConnectOnAppLaunchButton state] == NSOnState)];
		
		[newWorld release];
		
		[worldsAndPlayersOutlineView reloadData];
		
		if (isExpanded)
			[worldsAndPlayersOutlineView expandItem:newWorld];
  }
}

@end

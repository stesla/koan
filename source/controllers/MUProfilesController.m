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
- (IBAction) editWorld:(MUWorld *)world;
- (void) playerSheetDidEndAdding:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;
- (void) playerSheetDidEndEditing:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;
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
  
  [worldsAndPlayersOutlineView setTarget:self];
  [worldsAndPlayersOutlineView setDoubleAction:@selector(editClickedRow:)];

	[editSelectedRowButton setEnabled:NO];
	[removeSelectedRowButton setEnabled:NO];
}

#pragma mark -
#pragma mark Actions

- (IBAction) addPlayer:(id)sender
{
  [playerNameField setStringValue:@""];
  [playerPasswordField setStringValue:@""];
  [playerConnectOnAppLaunchButton setState:NSOffState];
  
  [playerEditorSheet makeFirstResponder:playerNameField];
  
  [NSApp beginSheet:playerEditorSheet
     modalForWindow:[self window]
      modalDelegate:self
     didEndSelector:@selector(playerSheetDidEndAdding:returnCode:contextInfo:)
        contextInfo:nil];
}

- (IBAction) addWorld:(id)sender
{
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
  
  [NSApp beginSheet:worldEditorSheet
     modalForWindow:[self window]
      modalDelegate:self
     didEndSelector:@selector(worldSheetDidEndAdding:returnCode:contextInfo:)
        contextInfo:nil];
}

- (IBAction) editClickedRow:(id)sender
{
  NSEvent *event = [NSApp currentEvent];
  NSPoint location = [worldsAndPlayersOutlineView convertPoint:[event locationInWindow] fromView:nil];
  int row = [worldsAndPlayersOutlineView rowAtPoint:location];
	
  if (row == -1)
    return;
	
	id item = [worldsAndPlayersOutlineView itemAtRow:row];
		
	if ([item isKindOfClass:[MUWorld class]])
		[self editWorld:item];
	else if ([item isKindOfClass:[MUPlayer class]])
		[self editPlayer:item];
}

- (IBAction) endEditingPlayer:(id)sender
{
  [playerEditorSheet orderOut:sender];
  [NSApp endSheet:playerEditorSheet returnCode:(sender == playerSaveButton ? MUEditOkay : MUEditCancel)];
}

- (IBAction) endEditingWorld:(id)sender
{
  [worldEditorSheet orderOut:sender];
  [NSApp endSheet:worldEditorSheet returnCode:(sender == worldSaveButton ? MUEditOkay : MUEditCancel)];
}

- (IBAction) editSelectedRow:(id)sender
{
	id item = [worldsAndPlayersOutlineView itemAtRow:[worldsAndPlayersOutlineView selectedRow]];
	
	if ([item isKindOfClass:[MUWorld class]])
		[self editWorld:item];
	else if ([item isKindOfClass:[MUPlayer class]])
		[self editPlayer:item];
}

- (IBAction) removeSelectedRow:(id)sender
{
	id item = [worldsAndPlayersOutlineView itemAtRow:[worldsAndPlayersOutlineView selectedRow]];
	
	if ([item isKindOfClass:[MUWorld class]])
		[self removeWorld:item];
	else if ([item isKindOfClass:[MUPlayer class]])
		[self removePlayer:item];
}

#pragma mark -
#pragma mark NSOutlineView data source

- (id) outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item
{
	if (item)
		return [[(MUWorld *) item players] objectAtIndex:index];
	else
		return [[MUWorldRegistry sharedRegistry] worldAtIndex:index];
}

- (BOOL) outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
	if ([item isKindOfClass:[MUWorld class]])
		return YES;
	else
		return NO;
}

- (int) outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
	if (item)
		return [[(MUWorld *) item players] count];
	else
		return [[MUWorldRegistry sharedRegistry] count];
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

#pragma mark -
#pragma mark NSOutlineView delegate

- (BOOL) outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
	return NO;
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
	if ([worldsAndPlayersOutlineView selectedRow] == -1)
	{
		[editSelectedRowButton setEnabled:NO];
		[removeSelectedRowButton setEnabled:NO];
	}
	else
	{
		[editSelectedRowButton setEnabled:YES];
		[removeSelectedRowButton setEnabled:YES];
	}
}

@end

#pragma mark -

@implementation MUProfilesController (Private)

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
        contextInfo:nil];
}

- (IBAction) editWorld:(MUWorld *)world
{
  J3ProxySettings * settings = [world proxySettings];
	
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
        contextInfo:nil];
}

- (void) playerSheetDidEndAdding:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	// FIXME.
	
	return;
	
  if (returnCode == MUEditOkay)
  {  
    MUWorld *selectedWorld = [self selectedWorld];
    MUPlayer *newPlayer = [[MUPlayer alloc] initWithName:[playerNameField stringValue]
                                                password:[playerPasswordField stringValue]
                                                   world:selectedWorld];
    
    [[[MUServices profileRegistry] profileForWorld:selectedWorld
																						player:newPlayer]
      setAutoconnect:([playerConnectOnAppLaunchButton state] == NSOnState)];
    
    [newPlayer release];
  }
}

- (void) playerSheetDidEndEditing:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	// FIXME.
	
	return;
	
  if (returnCode == MUEditOkay)
  {
    MUWorld *selectedWorld = [self selectedWorld];
    MUPlayer *selectedPlayer = [self selectedPlayer];
    MUPlayer *newPlayer = [[MUPlayer alloc] initWithName:[playerNameField stringValue]
                                                password:[playerPasswordField stringValue]
                                                   world:selectedWorld];
    // This updates the profile for the player with the new objects       
    [self updateProfileForWorld:selectedWorld
                         player:selectedPlayer
                     withPlayer:newPlayer];
    
    [[[MUServices profileRegistry] profileForWorld:selectedWorld
																						player:selectedPlayer]
      setAutoconnect:([playerConnectOnAppLaunchButton state] == NSOnState)];
		
    [newPlayer release];
  }
}

- (IBAction) removePlayer:(MUPlayer *)player
{
	// FIXME.
  
  [[MUServices profileRegistry] removeProfileForWorld:[player world]
																							 player:player];
}

- (IBAction) removeWorld:(MUWorld *)world
{
	// FIXME.
	
  [[MUServices profileRegistry] removeAllProfilesForWorld:world];
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
	// FIXME.
	
	return;
	
  if (returnCode == MUEditOkay)
  {
    MUWorld *world = [self createWorldFromSheetWithPlayers:[NSArray array]];
    
    [[[MUServices profileRegistry] profileForWorld:world]
      setAutoconnect:([worldConnectOnAppLaunchButton state] == NSOnState)];
  }
}

- (void) worldSheetDidEndEditing:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	// FIXME.
	
	return;
	
  if (returnCode == MUEditOkay)
  {
    MUWorld *selectedWorld = [self selectedWorld];
    MUWorld *newWorld = [self createWorldFromSheetWithPlayers:[selectedWorld players]];
		
    // This updates the world for every profile that has this world.
    [self updateProfilesForWorld:selectedWorld
                       withWorld:newWorld];
    
    // This changes the setting on just the profile for the world itself.
    [[[MUServices profileRegistry] profileForWorld:selectedWorld]
      setAutoconnect:([worldConnectOnAppLaunchButton state] == NSOnState)];
  }
}

@end

//
// MUProfilesController.m
//
// Copyright (C) 2004, 2005 3James Software
//

#import <J3Terminal/J3ProxySettings.h>
#import "MUProfilesController.h"
#import "J3PortFormatter.h"
#import "MUProfile.h"
#import "MUWorldRegistry.h"
#import "MUProfileRegistry.h"

enum MUProfilesEditingReturnValues
{
  MUEditOkay,
  MUEditCancel
};

@interface MUProfilesController (Private)

- (void) playerSheetDidEndAdding:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;
- (void) playerSheetDidEndEditing:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;
- (void) worldSheetDidEndAdding:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;
- (void) worldSheetDidEndEditing:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;

- (MUWorld *) createWorldFromSheetWithPlayers:(NSArray *)players;
- (void) updateProfilesForWorld:(MUWorld *)world withWorld:(MUWorld *)newWorld;
- (void) updateProfileForWorld:(MUWorld *)world 
                        player:(MUPlayer *)player 
                    withPlayer:(MUPlayer *)newPlayer;
- (MUWorld *) selectedWorld;
- (MUPlayer *) selectedPlayer;
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
  NSSortDescriptor *worldsSortDesc = [[NSSortDescriptor alloc] initWithKey:@"worldName" ascending:YES];
  NSSortDescriptor *playersSortDesc = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
  
  [worldPortField setFormatter:worldPortFormatter];
  [worldProxyPortField setFormatter:proxyPortFormatter];
  
  [playersTable setTarget:self];
  [playersTable setDoubleAction:@selector(editClickedPlayer:)];
  [worldsTable setTarget:self];
  [worldsTable setDoubleAction:@selector(editClickedWorld:)];
  
  [worldsArrayController setSortDescriptors:[NSArray arrayWithObject:worldsSortDesc]];
  [worldsSortDesc release];
  
  [playersArrayController setSortDescriptors:[NSArray arrayWithObject:playersSortDesc]];
  [playersSortDesc release];
}

- (MUWorldRegistry *) registry
{
  return [MUWorldRegistry sharedRegistry];
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

- (IBAction) editClickedPlayer:(id)sender
{
  NSEvent *event = [NSApp currentEvent];
  NSPoint location = [playersTable convertPoint:[event locationInWindow] fromView:nil];
  
  if ([playersTable rowAtPoint:location] == -1)
    return;
  
  [self editPlayer:sender];
}

- (IBAction) editClickedWorld:(id)sender
{
  NSEvent *event = [NSApp currentEvent];
  NSPoint location = [worldsTable convertPoint:[event locationInWindow] fromView:nil];
  
  if ([worldsTable rowAtPoint:location] == -1)
    return;
  
  [self editWorld:sender];
}

- (IBAction) editPlayer:(id)sender
{
  MUWorld *world = [self selectedWorld];
  MUPlayer *player = [self selectedPlayer];
  
  [playerNameField setStringValue:[player name]];
  [playerPasswordField setStringValue:[player password]];
  [playerConnectOnAppLaunchButton setState:
    ([[[MUProfileRegistry sharedRegistry] profileForWorld:world
                                                   player:player] autoconnect]
     ? NSOnState : NSOffState)];
  
  [playerEditorSheet makeFirstResponder:playerNameField];
  
  [NSApp beginSheet:playerEditorSheet
     modalForWindow:[self window]
      modalDelegate:self
     didEndSelector:@selector(playerSheetDidEndEditing:returnCode:contextInfo:)
        contextInfo:nil];
}

- (IBAction) editWorld:(id)sender
{
  MUWorld *world = [self selectedWorld];
  J3ProxySettings * settings = [world proxySettings];

  [worldNameField setStringValue:[world worldName]];
  [worldHostnameField setStringValue:[world worldHostname]];
  [worldPortField setObjectValue:[world worldPort]];
  [worldURLField setStringValue:[world worldURL]];
  [worldUsesSSLButton setState:([world usesSSL] ? NSOnState : NSOffState)];
  [worldConnectOnAppLaunchButton setState:
    ([[[MUProfileRegistry sharedRegistry] profileForWorld:world] autoconnect]
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

- (IBAction) removePlayer:(id)sender
{
  MUPlayer *player = [self selectedPlayer];
  
  [[MUProfileRegistry sharedRegistry] removeProfileForWorld:[player world]
                                                     player:player];
  
  [playersArrayController removeObject:player];
  [playersArrayController rearrangeObjects];
}

- (IBAction) removeWorld:(id)sender
{
  MUWorld *world = [self selectedWorld];
  [[MUProfileRegistry sharedRegistry] removeAllProfilesForWorld:world];
  [worldsArrayController removeObject:world];
  [worldsArrayController rearrangeObjects];
}

@end

#pragma mark -

@implementation MUProfilesController (Private)

- (void) playerSheetDidEndAdding:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
  if (returnCode == MUEditOkay)
  {  
    MUWorld *selectedWorld = [self selectedWorld];
    MUPlayer *newPlayer = [[MUPlayer alloc] initWithName:[playerNameField stringValue]
                                                password:[playerPasswordField stringValue]
                                                   world:selectedWorld];
    
    [[[MUProfileRegistry sharedRegistry] profileForWorld:selectedWorld
                                                  player:newPlayer]
      setAutoconnect:([playerConnectOnAppLaunchButton state] == NSOnState)];
    
    [playersArrayController addObject:newPlayer];
    [newPlayer release];
    [playersArrayController rearrangeObjects];
  }
}

- (void) playerSheetDidEndEditing:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
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
    
    [[[MUProfileRegistry sharedRegistry] profileForWorld:selectedWorld
                                                  player:selectedPlayer]
      setAutoconnect:([playerConnectOnAppLaunchButton state] == NSOnState)];

    
    
    [playersArrayController removeObject:selectedPlayer];
    [playersArrayController addObject:newPlayer];
    [newPlayer release];
    [playersArrayController rearrangeObjects];
  }
}

- (void) worldSheetDidEndAdding:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
  if (returnCode == MUEditOkay)
  {
    MUWorld *world = [self createWorldFromSheetWithPlayers:[NSArray array]];
    
    [[[MUProfileRegistry sharedRegistry] profileForWorld:world]
      setAutoconnect:([worldConnectOnAppLaunchButton state] == NSOnState)];

    [worldsArrayController addObject:world];
    [worldsArrayController rearrangeObjects];
  }
}

- (void) worldSheetDidEndEditing:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
  if (returnCode == MUEditOkay)
  {
    MUWorld *selectedWorld = [self selectedWorld];
    MUWorld *newWorld = [self createWorldFromSheetWithPlayers:[selectedWorld players]];

    // This updates the world for every profile that has this world
    [self updateProfilesForWorld:selectedWorld
                       withWorld:newWorld];
    
    // This changes the setting on just the profile for the world itself
    [[[MUProfileRegistry sharedRegistry] profileForWorld:selectedWorld]
      setAutoconnect:([worldConnectOnAppLaunchButton state] == NSOnState)];
    
    [worldsArrayController removeObject:selectedWorld];
    [worldsArrayController addObject:newWorld];
    [worldsArrayController rearrangeObjects];
  }
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

- (void) updateProfilesForWorld:(MUWorld *)world 
                      withWorld:(MUWorld *)newWorld

{
  MUProfile *profile = nil;
  MUProfileRegistry *registry = [MUProfileRegistry sharedRegistry];
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
  MUProfileRegistry *registry = [MUProfileRegistry sharedRegistry];
  MUProfile *profile = [registry profileForWorld:world
                                          player:player];
  [profile retain];
  [registry removeProfile:profile];
  [profile setPlayer:newPlayer];
  [registry profileForProfile:profile];
  [profile release];
}

- (MUWorld *) selectedWorld
{
  return [[worldsArrayController selectedObjects] objectAtIndex:0];
}

- (MUPlayer *) selectedPlayer
{
  return [[playersArrayController selectedObjects] objectAtIndex:0];
}


@end

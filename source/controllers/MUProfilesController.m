//
// MUProfilesController.m
//
// Copyright (C) 2004 3James Software
//

#import <J3Terminal/J3ProxySettings.h>
#import "MUProfilesController.h"
#import "J3PortFormatter.h"
#import "MUPlayer.h"
#import "MUWorld.h"
#import "MUWorldRegistry.h"

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
  [playerNameField setStringValue:[playersArrayController valueForKeyPath:@"selection.name"]];
  [playerPasswordField setStringValue:[playersArrayController valueForKeyPath:@"selection.password"]];
  [playerConnectOnAppLaunchButton setState:([[playersArrayController valueForKeyPath:@"selection.connectOnAppLaunch"] boolValue] ? NSOnState : NSOffState)];
  
  [playerEditorSheet makeFirstResponder:playerNameField];
  
  [NSApp beginSheet:playerEditorSheet
     modalForWindow:[self window]
      modalDelegate:self
     didEndSelector:@selector(playerSheetDidEndEditing:returnCode:contextInfo:)
        contextInfo:nil];
}

- (IBAction) editWorld:(id)sender
{
  J3ProxySettings * settings =
    [worldsArrayController valueForKeyPath:@"selection.proxySettings"];  

  [worldNameField setStringValue:[worldsArrayController valueForKeyPath:@"selection.worldName"]];
  [worldHostnameField setStringValue:[worldsArrayController valueForKeyPath:@"selection.worldHostname"]];
  [worldPortField setObjectValue:[worldsArrayController valueForKeyPath:@"selection.worldPort"]];
  [worldURLField setStringValue:[worldsArrayController valueForKeyPath:@"selection.worldURL"]];
  [worldConnectOnAppLaunchButton setState:([[worldsArrayController valueForKeyPath:@"selection.connectOnAppLaunch"] boolValue] ? NSOnState : NSOffState)];
  [worldUsesSSLButton setState:([[worldsArrayController valueForKeyPath:@"selection.usesSSL"] boolValue] ? NSOnState : NSOffState)];

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
  MUPlayer *player = [[playersArrayController selectedObjects] objectAtIndex:0];
  [playersArrayController removeObject:player];
  [playersArrayController rearrangeObjects];
}

- (IBAction) removeWorld:(id)sender
{
  MUWorld *world = [[worldsArrayController selectedObjects] objectAtIndex:0];
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
    MUWorld *selectedWorld = [[worldsArrayController selectedObjects] objectAtIndex:0];
    MUPlayer *newPlayer = [[MUPlayer alloc] initWithName:[playerNameField stringValue]
                                                password:[playerPasswordField stringValue]
                                      connectOnAppLaunch:([playerConnectOnAppLaunchButton state] == NSOnState ? YES : NO)
                                                   world:selectedWorld];
    
    [playersArrayController addObject:newPlayer];
    [newPlayer release];
    [playersArrayController rearrangeObjects];
  }
}

- (void) playerSheetDidEndEditing:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
  if (returnCode == MUEditOkay)
  {
    MUWorld *selectedWorld = [[worldsArrayController selectedObjects] objectAtIndex:0];
    MUWorld *selectedPlayer = [[playersArrayController selectedObjects] objectAtIndex:0];
    MUPlayer *newPlayer = [[MUPlayer alloc] initWithName:[playerNameField stringValue]
                                                password:[playerPasswordField stringValue]
                                      connectOnAppLaunch:([playerConnectOnAppLaunchButton state] == NSOnState ? YES : NO)
                                                   world:selectedWorld];
    
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
    [worldsArrayController addObject:[self createWorldFromSheetWithPlayers:[NSArray array]]];
    [worldsArrayController rearrangeObjects];
  }
}

- (void) worldSheetDidEndEditing:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
  if (returnCode == MUEditOkay)
  {
    MUWorld *selectedWorld = [[worldsArrayController selectedObjects] objectAtIndex:0];
    [worldsArrayController removeObject:selectedWorld];
    [worldsArrayController addObject:
      [self createWorldFromSheetWithPlayers:[selectedWorld players]]];
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
                         connectOnAppLaunch:([worldConnectOnAppLaunchButton state] == NSOnState ? YES : NO)
                                    usesSSL:([worldUsesSSLButton state] == NSOnState ? YES : NO)
                              proxySettings:settings
                                    players:players];
}

@end

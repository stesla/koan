//
// MUProfilesController.m
//
// Copyright (C) 2004 3James Software
//

#import "MUProfilesController.h"
#import "J3PortFormatter.h"
#import "MUPlayer.h"
#import "MUWorld.h"

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
  [worldNameField setStringValue:[worldsArrayController valueForKeyPath:@"selection.worldName"]];
  [worldHostnameField setStringValue:[worldsArrayController valueForKeyPath:@"selection.worldHostname"]];
  [worldPortField setObjectValue:[worldsArrayController valueForKeyPath:@"selection.worldPort"]];
  [worldURLField setStringValue:[worldsArrayController valueForKeyPath:@"selection.worldURL"]];
  [worldConnectOnAppLaunchButton setState:([[worldsArrayController valueForKeyPath:@"selection.connectOnAppLaunch"] boolValue] ? NSOnState : NSOffState)];
  [worldUsesSSLButton setState:([[worldsArrayController valueForKeyPath:@"selection.usesSSL"] boolValue] ? NSOnState : NSOffState)];
  [worldUsesProxyButton setState:([[worldsArrayController valueForKeyPath:@"selection.usesProxy"] boolValue] ? NSOnState : NSOffState)];
  [worldProxyHostnameField setStringValue:[worldsArrayController valueForKeyPath:@"selection.proxyHostname"]];
  [worldProxyPortField setObjectValue:[worldsArrayController valueForKeyPath:@"selection.proxyPort"]];
  [worldProxyVersionButton selectItemAtIndex:([[worldsArrayController valueForKeyPath:@"selection.proxyVersion"] intValue] == 4 ? 0 : 1)];
  [worldProxyUsernameField setStringValue:[worldsArrayController valueForKeyPath:@"selection.proxyUsername"]];
  [worldProxyPasswordField setStringValue:[worldsArrayController valueForKeyPath:@"selection.proxyPassword"]];
  
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
    MUWorld *newWorld = [[MUWorld alloc] initWithWorldName:[worldNameField stringValue]
                                             worldHostname:[worldHostnameField stringValue]
                                                 worldPort:[NSNumber numberWithInt:[worldPortField intValue]]
                                                  worldURL:[worldURLField stringValue]
                                        connectOnAppLaunch:([worldConnectOnAppLaunchButton state] == NSOnState ? YES : NO)
                                                   usesSSL:([worldUsesSSLButton state] == NSOnState ? YES : NO)
                                                 usesProxy:([worldUsesProxyButton state] == NSOnState ? YES : NO)
                                             proxyHostname:[worldProxyHostnameField stringValue]
                                                 proxyPort:[NSNumber numberWithInt:[worldProxyPortField intValue]]
                                              proxyVersion:([worldProxyVersionButton indexOfSelectedItem] == 0 ? 4 : 5)
                                             proxyUsername:[worldProxyUsernameField stringValue]
                                             proxyPassword:[worldProxyPasswordField stringValue]
                                                   players:[NSArray array]];
    
    [worldsArrayController addObject:newWorld];
    [newWorld release];
    [worldsArrayController rearrangeObjects];
  }
}

- (void) worldSheetDidEndEditing:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
  if (returnCode == MUEditOkay)
  {
    MUWorld *selectedWorld = [[worldsArrayController selectedObjects] objectAtIndex:0];
    MUWorld *newWorld = [[MUWorld alloc] initWithWorldName:[worldNameField stringValue]
                                             worldHostname:[worldHostnameField stringValue]
                                                 worldPort:[NSNumber numberWithInt:[worldPortField intValue]]
                                                  worldURL:[worldURLField stringValue]
                                        connectOnAppLaunch:([worldConnectOnAppLaunchButton state] == NSOnState ? YES : NO)
                                                   usesSSL:([worldUsesSSLButton state] == NSOnState ? YES : NO)
                                                 usesProxy:([worldUsesProxyButton state] == NSOnState ? YES : NO)
                                             proxyHostname:[worldProxyHostnameField stringValue]
                                                 proxyPort:[NSNumber numberWithInt:[worldProxyPortField intValue]]
                                              proxyVersion:([worldProxyVersionButton indexOfSelectedItem] == 0 ? 4 : 5)
                                             proxyUsername:[worldProxyUsernameField stringValue]
                                             proxyPassword:[worldProxyPasswordField stringValue]
                                                   players:[selectedWorld players]];
    
    [worldsArrayController removeObject:selectedWorld];
    [worldsArrayController addObject:newWorld];
    [newWorld release];
    [worldsArrayController rearrangeObjects];
  }
}

@end

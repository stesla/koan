//
// MUProfilesController.m
//
// Copyright (c) 2004, 2005, 2006, 2007 3James Software
//

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

- (IBAction) changeFont: (id) sender;
- (void) colorPanelColorDidChange: (NSNotification *) notification;
- (IBAction) editPlayer: (MUPlayer *) player;
- (IBAction) editProfile: (MUProfile *) player;
- (IBAction) editWorld: (MUWorld *) world;
- (void) globalBackgroundColorDidChange: (NSNotification *) notification;
- (void) globalFontDidChange: (NSNotification *) notification;
- (void) globalLinkColorDidChange: (NSNotification *) notification;
- (void) globalTextColorDidChange: (NSNotification *) notification;
- (void) globalVisitedLinkColorDidChange: (NSNotification *) notification;
- (void) playerSheetDidEndAdding: (NSWindow *) sheet returnCode: (int) returnCode contextInfo: (void *) contextInfo;
- (void) playerSheetDidEndEditing: (NSWindow *) sheet returnCode: (int) returnCode contextInfo: (void *) contextInfo;
- (void) profileSheetDidEndEditing: (NSWindow *) sheet returnCode: (int) returnCode contextInfo: (void *) contextInfo;
- (void) registerForNotifications;
- (IBAction) removePlayer: (MUPlayer *) player;
- (IBAction) removeWorld: (MUWorld *) world;
- (void) updateProfilesForWorld: (MUWorld *) world withWorld: (MUWorld *) newWorld;
- (void) updateProfileForWorld: (MUWorld *) world
                        player: (MUPlayer *) player
                    withPlayer: (MUPlayer *) newPlayer;
- (MUWorld *) worldFromSheetWithPlayers: (NSArray *) players;
- (void) worldSheetDidEndAdding: (NSWindow *) sheet returnCode: (int) returnCode contextInfo: (void *) contextInfo;
- (void) worldSheetDidEndEditing: (NSWindow *) sheet returnCode: (int) returnCode contextInfo: (void *) contextInfo;

@end

#pragma mark -

@implementation MUProfilesController

- (id) init
{
  return [super initWithWindowNibName: @"MUProfiles"];
}

- (void) awakeFromNib
{
  J3PortFormatter *worldPortFormatter = [[[J3PortFormatter alloc] init] autorelease];
  
  [worldPortField setFormatter: worldPortFormatter];
  
  [worldsAndPlayersOutlineView setAutosaveExpandedItems: YES];
  [worldsAndPlayersOutlineView setTarget: self];
  [worldsAndPlayersOutlineView setDoubleAction: @selector (editClickedRow:)];
  
  editingFont = nil;
  
  backgroundColorActive = NO;
  linkColorActive = NO;
  textColorActive = NO;
  visitedLinkColorActive = NO;
  
  [self registerForNotifications];
}

- (BOOL) validateToolbarItem: (NSToolbarItem *) toolbarItem
{
  SEL toolbarItemAction = [toolbarItem action];
  
  if (toolbarItemAction == @selector (addWorld:))
  {
  	return YES;
  }
  else if (toolbarItemAction == @selector (addPlayer:)
  				 || toolbarItemAction == @selector (editProfileForSelectedRow:))
  {
  	if ([worldsAndPlayersOutlineView numberOfSelectedRows] == 0)
  		return NO;
  	else
  		return YES;
  }
  else if (toolbarItemAction == @selector (editSelectedRow:))
  {
  	if ([worldsAndPlayersOutlineView numberOfSelectedRows] == 0)
  	{
  		[toolbarItem setLabel: _(MULEditItem)];
  		return NO;
  	}
  	else
  	{
  		id item = [worldsAndPlayersOutlineView itemAtRow: [worldsAndPlayersOutlineView selectedRow]];
  		
  		if ([item isKindOfClass: [MUWorld class]])
  			[toolbarItem setLabel: _(MULEditWorld)];
  		else if ([item isKindOfClass: [MUPlayer class]])
  			[toolbarItem setLabel: _(MULEditPlayer)];
      else return NO;
  		
  		return YES;
  	}
  }
  else if (toolbarItemAction == @selector (removeSelectedRow:))
  {
  	if ([worldsAndPlayersOutlineView numberOfSelectedRows] == 0)
  	{
  		[toolbarItem setLabel: _(MULRemoveItem)];
  		return NO;
  	}
  	else
  	{
  		id item = [worldsAndPlayersOutlineView itemAtRow: [worldsAndPlayersOutlineView selectedRow]];
  		
  		if ([item isKindOfClass: [MUWorld class]])
  			[toolbarItem setLabel: _(MULRemoveWorld)];
  		else if ([item isKindOfClass: [MUPlayer class]])
  			[toolbarItem setLabel: _(MULRemovePlayer)];
      else return NO;
  		
  		return YES;
  	}
  }
  else if (toolbarItemAction == @selector (goToWorldURL:))
  {
    if ([worldsAndPlayersOutlineView numberOfSelectedRows] == 0)
  	{
  		return NO;
  	}
  	else
  	{
  		id item = [worldsAndPlayersOutlineView itemAtRow: [worldsAndPlayersOutlineView selectedRow]];
  		NSString *url = nil;
      
  		if ([item isKindOfClass: [MUWorld class]])
      {
        url = [(MUWorld *) item URL];
      }
  		else if ([item isKindOfClass: [MUPlayer class]])
  		{
        url = [[(MUPlayer *) item world] URL];
      }
      
      return (url && ![url isEqualToString: @""]);
  	}
  }
  
  return NO;
}

#pragma mark -
#pragma mark Actions

- (IBAction) addPlayer: (id) sender
{
  int selectedRow = [worldsAndPlayersOutlineView selectedRow];
  MUWorld *insertionWorld;
  int insertionIndex;
  NSDictionary *contextDictionary;
  
  [playerNameField setStringValue: @""];
  [playerPasswordField setStringValue: @""];
  
  [playerEditorSheet makeFirstResponder: playerNameField];
  
  if (selectedRow == -1)
  	return;
  else
  {
  	id selectedItem;
  	
  	selectedItem = [worldsAndPlayersOutlineView itemAtRow: selectedRow];
  	
  	if ([selectedItem isKindOfClass: [MUWorld class]])
  	{
  		insertionWorld = (MUWorld *) selectedItem;
  		insertionIndex = [[insertionWorld players] count];
  	}
  	else if ([selectedItem isKindOfClass: [MUPlayer class]])
  	{
  		MUPlayer *selectedPlayer = (MUPlayer *) selectedItem;
  		int playerIndex = [[selectedPlayer world] indexOfPlayer: selectedPlayer] + 1;
  		
  		if (playerIndex < 0)
  			return;
  		
  		insertionIndex = (unsigned) playerIndex;
  		insertionWorld = [selectedPlayer world];
  	}
  	else
  		return;
  }
  
  contextDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
  	[NSNumber numberWithUnsignedInt: insertionIndex], MUInsertionIndex,
  	insertionWorld, MUInsertionWorld,
  	NULL];
  
  [NSApp beginSheet: playerEditorSheet
     modalForWindow: [self window]
      modalDelegate: self
     didEndSelector: @selector (playerSheetDidEndAdding:returnCode:contextInfo:)
        contextInfo: contextDictionary];
}

- (IBAction) addWorld: (id) sender
{
  int selectedRow = [worldsAndPlayersOutlineView selectedRow];
  int insertionIndex;
  
  [worldNameField setStringValue: @""];
  [worldHostnameField setStringValue: @""];
  [worldPortField setStringValue: @""];
  [worldURLField setStringValue: @""];
  
  [worldEditorSheet makeFirstResponder: worldNameField];
  
  if (selectedRow == -1)
  	insertionIndex = [[MUServices worldRegistry] count];
  else
  {
  	id selectedItem = [worldsAndPlayersOutlineView itemAtRow: selectedRow];
    
  	MUWorld *selectedWorld = nil;
  	
  	if ([selectedItem isKindOfClass: [MUWorld class]])
  		selectedWorld = (MUWorld *) selectedItem;
  	else if ([selectedItem isKindOfClass: [MUPlayer class]])
  		selectedWorld = [(MUPlayer *) selectedItem world];
  	
    if (selectedWorld)
      insertionIndex = [[MUServices worldRegistry] indexOfWorld: selectedWorld] + 1;
    else
      insertionIndex = [[MUServices worldRegistry] count];
  }
  
  [NSApp beginSheet: worldEditorSheet
     modalForWindow: [self window]
      modalDelegate: self
     didEndSelector: @selector (worldSheetDidEndAdding:returnCode:contextInfo:)
        contextInfo: [[NSNumber alloc] initWithUnsignedInt: insertionIndex]];
}

- (IBAction) chooseNewFont: (id) sender
{
  NSDictionary *values = [[NSUserDefaultsController sharedUserDefaultsController] values];
  NSString *fontName = [values valueForKey: MUPFontName];
  int fontSize = [[values valueForKey: MUPFontSize] floatValue];
  NSFont *font = [NSFont fontWithName: fontName size: fontSize];
  
  if (font == nil)
  {
    font = [NSFont systemFontOfSize: [NSFont systemFontSize]];
  }
  
  [[NSFontManager sharedFontManager] setSelectedFont: font isMultiple: NO];
  [[NSFontManager sharedFontManager] orderFrontFontPanel: self];
}

- (IBAction) editClickedRow: (id) sender
{
  NSEvent *event = [NSApp currentEvent];
  NSPoint location = [worldsAndPlayersOutlineView convertPoint: [event locationInWindow] fromView: nil];
  int row = [worldsAndPlayersOutlineView rowAtPoint: location];
  id clickedItem;
  
  if (row == -1)
    return;
  
  clickedItem = [worldsAndPlayersOutlineView itemAtRow: row];
  	
  if ([clickedItem isKindOfClass: [MUWorld class]])
  	[self editWorld: clickedItem];
  else if ([clickedItem isKindOfClass: [MUPlayer class]])
  	[self editPlayer: clickedItem];
}

- (IBAction) editProfileForSelectedRow: (id) sender
{
  int selectedRow = [worldsAndPlayersOutlineView selectedRow];
  id selectedItem;
  
  if (selectedRow == -1)
  	return;
  
  selectedItem = [worldsAndPlayersOutlineView itemAtRow: selectedRow];
  
  if ([selectedItem isKindOfClass: [MUWorld class]])
  	[self editProfile: [[MUProfileRegistry defaultRegistry] profileForWorld: selectedItem]];
  else if ([selectedItem isKindOfClass: [MUPlayer class]])
  	[self editProfile: [[MUProfileRegistry defaultRegistry] profileForWorld: [(MUPlayer *) selectedItem world]
                                                                    player: selectedItem]];
}

- (IBAction) editSelectedRow: (id) sender
{
  int selectedRow = [worldsAndPlayersOutlineView selectedRow];
  id selectedItem;
  
  if (selectedRow == -1)
  	return;
  
  selectedItem = [worldsAndPlayersOutlineView itemAtRow: selectedRow];
  
  if ([selectedItem isKindOfClass: [MUWorld class]])
  	[self editWorld: selectedItem];
  else if ([selectedItem isKindOfClass: [MUPlayer class]])
  	[self editPlayer: selectedItem];
}

- (IBAction) endEditingPlayer: (id) sender
{
  [playerEditorSheet orderOut: sender];
  [NSApp endSheet: playerEditorSheet returnCode: (sender == playerSaveButton ? MUEditOkay : MUEditCancel)];
}

- (IBAction) endEditingProfile: (id) sender
{
  [profileEditorSheet orderOut: sender];
  [NSApp endSheet: profileEditorSheet returnCode: (sender == profileSaveButton ? MUEditOkay : MUEditCancel)];
}

- (IBAction) endEditingWorld: (id) sender
{
  [worldEditorSheet orderOut: sender];
  [NSApp endSheet: worldEditorSheet returnCode: (sender == worldSaveButton ? MUEditOkay : MUEditCancel)];
}

- (IBAction) goToWorldURL: (id) sender
{
  int selectedRow = [worldsAndPlayersOutlineView selectedRow];
  id selectedItem;
  
  if (selectedRow == -1)
  	return;
  
  selectedItem = [worldsAndPlayersOutlineView itemAtRow: selectedRow];
  
  if ([selectedItem isKindOfClass: [MUWorld class]])
  	[[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString: [(MUWorld *) selectedItem URL]]];
  else if ([selectedItem isKindOfClass: [MUPlayer class]])
  	[[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString: [[(MUPlayer *) selectedItem world] URL]]];
}

- (IBAction) removeSelectedRow: (id) sender
{
  int selectedRow = [worldsAndPlayersOutlineView selectedRow];
  id selectedItem;
  
  if (selectedRow == -1)
  	return;
  
  selectedItem = [worldsAndPlayersOutlineView itemAtRow: selectedRow];
  
  if ([selectedItem isKindOfClass: [MUWorld class]])
  	[self removeWorld: selectedItem];
  else if ([selectedItem isKindOfClass: [MUPlayer class]])
  	[self removePlayer: selectedItem];
}

- (IBAction) useGlobalBackgroundColor: (id) sender
{
  if ([sender state] == NSOnState)
  {
    NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
    NSColor *color = [NSUnarchiver unarchiveObjectWithData: [[defaults values] valueForKey: MUPBackgroundColor]];
    
    [profileBackgroundColorWell setColor: color];
  }
}

- (IBAction) useGlobalFont: (id) sender
{
  if ([sender state] == NSOnState)
  {
    NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
  	NSString *fontName = [[defaults values] valueForKey: MUPFontName];
  	NSNumber *fontSize = [[defaults values] valueForKey: MUPFontSize];
    
    [editingFont release];
    editingFont = nil;
  	
  	[profileFontField setStringValue: [[NSFont fontWithName: fontName size: [fontSize floatValue]] fullDisplayName]];
  }
}

- (IBAction) useGlobalLinkColor: (id) sender
{
  if ([sender state] == NSOnState)
  {
    NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
    NSColor *color = [NSUnarchiver unarchiveObjectWithData: [[defaults values] valueForKey: MUPLinkColor]];
    
    [profileLinkColorWell setColor: color];
  }
}

- (IBAction) useGlobalTextColor: (id) sender
{
  if ([sender state] == NSOnState)
  {
    NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
    NSColor *color = [NSUnarchiver unarchiveObjectWithData: [[defaults values] valueForKey: MUPTextColor]];
    
    [profileTextColorWell setColor: color];
  }
}

- (IBAction) useGlobalVisitedLinkColor: (id) sender
{
  if ([sender state] == NSOnState)
  {
    NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
    NSColor *color = [NSUnarchiver unarchiveObjectWithData: [[defaults values] valueForKey: MUPVisitedLinkColor]];
    
    [profileVisitedLinkColorWell setColor: color];
  }
}

#pragma mark -
#pragma mark NSOutlineView data source

- (id) outlineView: (NSOutlineView *) outlineView child: (int) itemIndex ofItem: (id) item
{
  if (item)
  	return [[(MUWorld *) item players] objectAtIndex: itemIndex];
  else
  	return [[MUServices worldRegistry] worldAtIndex: itemIndex];
}

- (BOOL) outlineView: (NSOutlineView *) outlineView isItemExpandable: (id) item
{
  if ([item isKindOfClass: [MUWorld class]])
  	return YES;
  else
  	return NO;
}

- (id) outlineView: (NSOutlineView *) outlineView itemForPersistentObject: (id) object
{
  if (object && [object isKindOfClass: [NSString class]])
  {
  	return [[MUServices worldRegistry] worldForUniqueIdentifier: (NSString *) object];
  }
  
  return nil;
}

- (int) outlineView: (NSOutlineView *) outlineView numberOfChildrenOfItem: (id) item
{
  if (item)
  	return [[(MUWorld *) item players] count];
  else
  	return [[MUServices worldRegistry] count];
}

- (id) outlineView: (NSOutlineView *) outlineView objectValueForTableColumn: (NSTableColumn *) column byItem: (id) item
{
  if ([item isKindOfClass: [MUWorld class]])
  	return [(MUWorld *) item name];
  else if ([item isKindOfClass: [MUPlayer class]])
  	return [(MUPlayer *) item name];
  else
  	return item;
}

- (id) outlineView: (NSOutlineView *) outlineView persistentObjectForItem: (id) item
{
  if ([item isKindOfClass: [MUWorld class]])
  	return [(MUWorld *) item uniqueIdentifier];
  else
  	return nil;
}

#pragma mark -
#pragma mark NSOutlineView delegate

- (BOOL) outlineView: (NSOutlineView *) outlineView shouldEditTableColumn: (NSTableColumn *) tableColumn item: (id) item
{
  return NO;
}

@end

#pragma mark -

@implementation MUProfilesController (Private)

- (IBAction) changeFont: (id) sender
{
  NSFontManager *fontManager = [NSFontManager sharedFontManager];
  NSFont *selectedFont = [fontManager selectedFont];
  NSFont *panelFont;
  
  if (selectedFont == nil)
  {
    selectedFont = [NSFont systemFontOfSize: [NSFont systemFontSize]];
  }
  
  panelFont = [fontManager convertFont: selectedFont];
  
  [profileFontUseGlobalButton setState: NSOffState];
  [profileFontField setStringValue: [panelFont fullDisplayName]];
  editingFont = [panelFont copy];
}

- (void) colorPanelColorDidChange: (NSNotification *) notification
{
  if ([profileBackgroundColorWell isActive])
  {
    if (backgroundColorActive)
      [profileBackgroundColorUseGlobalButton setState: NSOffState];
    else
    {
      backgroundColorActive = YES;
      linkColorActive = NO;
      textColorActive = NO;
      visitedLinkColorActive = NO;
    }
  }
  else if ([profileLinkColorWell isActive])
  {
    if (linkColorActive)
      [profileLinkColorUseGlobalButton setState: NSOffState];
    else
    {
      backgroundColorActive = NO;
      linkColorActive = YES;
      textColorActive = NO;
      visitedLinkColorActive = NO;
    }
  }
  else if ([profileTextColorWell isActive])
  {
    if (textColorActive)
      [profileTextColorUseGlobalButton setState: NSOffState];
    else
    {
      backgroundColorActive = NO;
      linkColorActive = NO;
      textColorActive = YES;
      visitedLinkColorActive = NO;
    }
  }
  else if ([profileVisitedLinkColorWell isActive])
  {
    if (visitedLinkColorActive)
      [profileVisitedLinkColorUseGlobalButton setState: NSOffState];
    else
    {
      backgroundColorActive = NO;
      linkColorActive = NO;
      textColorActive = NO;
      visitedLinkColorActive = YES;
    }
  }
  else
  {
    backgroundColorActive = NO;
    linkColorActive = NO;
    textColorActive = NO;
    visitedLinkColorActive = NO;
  }
}

- (IBAction) editPlayer: (MUPlayer *) player
{
  [playerNameField setStringValue: [player name]];
  [playerPasswordField setStringValue: [player password]];
  
  [playerEditorSheet makeFirstResponder: playerNameField];
  
  [NSApp beginSheet: playerEditorSheet
     modalForWindow: [self window]
      modalDelegate: self
     didEndSelector: @selector (playerSheetDidEndEditing:returnCode:contextInfo:)
        contextInfo: player];
}

- (IBAction) editProfile: (MUProfile *) profile
{
  editingProfile = [profile retain];
  
  [profileAutoconnectButton setState: ([profile autoconnect] ? NSOnState : NSOffState)];
  
  [profileFontField setStringValue: [profile effectiveFontDisplayName]];
  [profileFontUseGlobalButton setState: ([profile font] == nil ? NSOnState : NSOffState)];
  
  [profileTextColorWell setColor: [NSUnarchiver unarchiveObjectWithData: [profile effectiveTextColor]]];
  [profileTextColorUseGlobalButton setState: ([profile textColor] == nil ? NSOnState : NSOffState)];
  
  [profileBackgroundColorWell setColor: [NSUnarchiver unarchiveObjectWithData: [profile effectiveBackgroundColor]]];
  [profileBackgroundColorUseGlobalButton setState: ([profile backgroundColor] == nil ? NSOnState : NSOffState)];
  
  [profileLinkColorWell setColor: [NSUnarchiver unarchiveObjectWithData: [profile effectiveLinkColor]]];
  [profileLinkColorUseGlobalButton setState: ([profile linkColor] == nil ? NSOnState : NSOffState)];
  
  [profileVisitedLinkColorWell setColor: [NSUnarchiver unarchiveObjectWithData: [profile effectiveVisitedLinkColor]]];
  [profileVisitedLinkColorUseGlobalButton setState: ([profile visitedLinkColor] == nil ? NSOnState : NSOffState)];
  
  [NSApp beginSheet: profileEditorSheet
     modalForWindow: [self window]
      modalDelegate: self
     didEndSelector: @selector (profileSheetDidEndEditing:returnCode:contextInfo:)
        contextInfo: nil];
}

- (IBAction) editWorld: (MUWorld *) world
{
  [worldNameField setStringValue: [world name]];
  [worldHostnameField setStringValue: [world hostname]];
  [worldPortField setObjectValue: [world port]];
  [worldURLField setStringValue: [world URL]];
  
  [worldEditorSheet makeFirstResponder: worldNameField];
  
  [NSApp beginSheet: worldEditorSheet
     modalForWindow: [self window]
      modalDelegate: self
     didEndSelector: @selector (worldSheetDidEndEditing:returnCode:contextInfo:)
        contextInfo: world];
}

- (void) globalBackgroundColorDidChange: (NSNotification *) notification
{
  if (editingProfile && [profileBackgroundColorUseGlobalButton state] == NSOnState)
  {
    NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
    NSData *colorData = [[defaults values] valueForKey: MUPBackgroundColor];
    
    [profileBackgroundColorWell setColor: [NSUnarchiver unarchiveObjectWithData: colorData]];
  }
}

- (void) globalFontDidChange: (NSNotification *) notification
{
  if (editingProfile && [profileFontUseGlobalButton state] == NSOnState)
  {
    NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
  	NSString *fontName = [[defaults values] valueForKey: MUPFontName];
  	NSNumber *fontSize = [[defaults values] valueForKey: MUPFontSize];
    
    [editingFont release];
    editingFont = nil;
    
  	[profileFontField setStringValue: [[NSFont fontWithName: fontName size: [fontSize floatValue]] fullDisplayName]];
  }
}

- (void) globalLinkColorDidChange: (NSNotification *) notification
{
  if (editingProfile && [profileBackgroundColorUseGlobalButton state] == NSOnState)
  {
    NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
    NSData *colorData = [[defaults values] valueForKey: MUPLinkColor];
    
    [profileLinkColorWell setColor: [NSUnarchiver unarchiveObjectWithData: colorData]];
  }
}

- (void) globalTextColorDidChange: (NSNotification *) notification
{
  if (editingProfile && [profileTextColorUseGlobalButton state] == NSOnState)
  {
    NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
    NSData *colorData = [[defaults values] valueForKey: MUPTextColor];
    
    [profileTextColorWell setColor: [NSUnarchiver unarchiveObjectWithData: colorData]];
  }
}

- (void) globalVisitedLinkColorDidChange: (NSNotification *) notification
{
  if (editingProfile && [profileBackgroundColorUseGlobalButton state] == NSOnState)
  {
    NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
    NSData *colorData = [[defaults values] valueForKey: MUPVisitedLinkColor];
    
    [profileVisitedLinkColorWell setColor: [NSUnarchiver unarchiveObjectWithData: colorData]];
  }
}

- (void) playerSheetDidEndAdding: (NSWindow *) sheet returnCode: (int) returnCode contextInfo: (void *) contextInfo
{
  if (returnCode == MUEditOkay)
  {
  	NSDictionary *contextDictionary = (NSDictionary *) contextInfo;
  	unsigned insertionIndex = [(NSNumber *) [contextDictionary objectForKey: MUInsertionIndex] unsignedIntValue];
  	MUWorld *insertionWorld = (MUWorld *) [contextDictionary objectForKey: MUInsertionWorld];
    MUPlayer *newPlayer = [MUPlayer playerWithName: [playerNameField stringValue]
  																				password: [playerPasswordField stringValue]
  																					 world: insertionWorld];
    
  	[insertionWorld insertObject: newPlayer inPlayersAtIndex: insertionIndex];
  	
  	[worldsAndPlayersOutlineView reloadData];
  }
  
  [(NSObject *) contextInfo release];
}

- (void) playerSheetDidEndEditing: (NSWindow *) sheet returnCode: (int) returnCode contextInfo: (void *) contextInfo
{
  if (returnCode == MUEditOkay)
  {
  	MUPlayer *oldPlayer = (MUPlayer *) contextInfo;
    MUWorld *oldWorld = [oldPlayer world];
    MUPlayer *newPlayer = [MUPlayer playerWithName: [playerNameField stringValue]
  																				password: [playerPasswordField stringValue]
  																					 world: oldWorld];
  	
    // Updates the profile for the player/world with the new player object.
    [self updateProfileForWorld: oldWorld
                         player: oldPlayer
                     withPlayer: newPlayer];
  	
  	// Actually replace the old player with the new one.
  	[oldWorld replacePlayer: oldPlayer withPlayer: newPlayer];
  	
  	[worldsAndPlayersOutlineView reloadData];
  }
}

- (void) profileSheetDidEndEditing: (NSWindow *) sheet returnCode: (int) returnCode contextInfo: (void *) contextInfo
{  
  if (returnCode == MUEditOkay)
  {
    [editingProfile setAutoconnect: ([profileAutoconnectButton state] == NSOnState ? YES : NO)];
    
    if ([profileBackgroundColorUseGlobalButton state] == NSOnState)
      [editingProfile setValue: nil forKey: @"backgroundColor"];
    else
      [editingProfile setValue: [profileBackgroundColorWell color]
                        forKey: @"backgroundColor"];
    
    if ([profileFontUseGlobalButton state] == NSOnState)
      [editingProfile setValue: nil forKey: @"font"];
    else
      [editingProfile setValue: editingFont forKey: @"font"];
    
    if ([profileLinkColorUseGlobalButton state] == NSOnState)
      [editingProfile setValue: nil forKey: @"linkColor"];
    else
      [editingProfile setValue: [profileLinkColorWell color]
                        forKey: @"linkColor"];
    
    if ([profileTextColorUseGlobalButton state] == NSOnState)
      [editingProfile setValue: nil forKey: @"textColor"];
    else
      [editingProfile setValue: [profileTextColorWell color]
                        forKey: @"textColor"];
    
    if ([profileVisitedLinkColorUseGlobalButton state] == NSOnState)
      [editingProfile setValue: nil forKey: @"visitedLinkColor"];
    else
      [editingProfile setValue: [profileVisitedLinkColorWell color]
                        forKey: @"visitedLinkColor"];
  }
  
  [editingProfile release];
  editingProfile = nil;
  
  [editingFont release];
  editingFont = nil;
}

- (void) registerForNotifications
{
  [[NSNotificationCenter defaultCenter] addObserver: self
                                           selector: @selector (colorPanelColorDidChange:)
                                               name: NSColorPanelColorDidChangeNotification
                                             object: nil];
  
  [[NSNotificationCenter defaultCenter] addObserver: self
  																				 selector: @selector (globalBackgroundColorDidChange:)
  																						 name: MUGlobalBackgroundColorDidChangeNotification
  																					 object: nil];
  	
  [[NSNotificationCenter defaultCenter] addObserver: self
  																				 selector: @selector (globalFontDidChange:)
  																						 name: MUGlobalFontDidChangeNotification
  																					 object: nil];
  	
  [[NSNotificationCenter defaultCenter] addObserver: self
  																				 selector: @selector (globalLinkColorDidChange:)
  																						 name: MUGlobalLinkColorDidChangeNotification
  																					 object: nil];
  	
  [[NSNotificationCenter defaultCenter] addObserver: self
  																				 selector: @selector (globalTextColorDidChange:)
  																						 name: MUGlobalTextColorDidChangeNotification
  																					 object: nil];
  	
  [[NSNotificationCenter defaultCenter] addObserver: self
  																				 selector: @selector (globalVisitedLinkColorDidChange:)
  																						 name: MUGlobalVisitedLinkColorDidChangeNotification
  																					 object: nil];
}

- (IBAction) removePlayer: (MUPlayer *) player
{
  [[MUServices profileRegistry] removeProfileForWorld: [player world]
  																						 player: player];
  [[player world] removePlayer: player];
  
  [worldsAndPlayersOutlineView reloadData];
}

- (IBAction) removeWorld: (MUWorld *) world
{
  [[MUServices profileRegistry] removeAllProfilesForWorld: world];
  [[MUServices worldRegistry] removeWorld: world];
  
  [worldsAndPlayersOutlineView reloadData];
}

- (void) updateProfilesForWorld: (MUWorld *) world
                      withWorld: (MUWorld *) newWorld
{
  MUProfile *profile = nil;
  MUProfileRegistry *registry = [MUServices profileRegistry];
  NSArray *players = [world players];
  int i, count = [players count];
  
  for (i = 0; i < count; i++)
  {
    MUPlayer *player = [players objectAtIndex: i];
    profile = [registry profileForWorld: world
                                 player: player];
    [profile retain];
    [registry removeProfile: profile];
    [profile setWorld: newWorld];
    [player setWorld: newWorld];
    [registry profileForProfile: profile];
    [profile release];
  }
  
  profile = [registry profileForWorld: world];
  [profile retain];
  [registry removeProfile: profile];
  [profile setWorld: newWorld];
  [registry profileForProfile: profile];
  [profile release];
}

- (void) updateProfileForWorld: (MUWorld *) world
                        player: (MUPlayer *) player
                    withPlayer: (MUPlayer *) newPlayer
{
  MUProfileRegistry *registry = [MUServices profileRegistry];
  MUProfile *profile = [registry profileForWorld: world
                                          player: player];
  [profile retain];
  [registry removeProfile: profile];
  [profile setPlayer: newPlayer];
  [registry profileForProfile: profile];
  [profile release];
}

- (MUWorld *) worldFromSheetWithPlayers: (NSArray *) players
{
  return [MUWorld worldWithName: [worldNameField stringValue]
  										 hostname: [worldHostnameField stringValue]
  												 port: [NSNumber numberWithInt: [worldPortField intValue]]
  													URL: [worldURLField stringValue]
  											players: players];
}

- (void) worldSheetDidEndAdding: (NSWindow *) sheet returnCode: (int) returnCode contextInfo: (void *) contextInfo
{
  if (returnCode == MUEditOkay)
  {
    MUWorld *newWorld = [self worldFromSheetWithPlayers: [NSArray array]];
  	unsigned insertionIndex = [(NSNumber *) contextInfo unsignedIntValue];
  	
  	[[MUServices worldRegistry] insertObject: newWorld inWorldsAtIndex: insertionIndex];
  	
  	[worldsAndPlayersOutlineView reloadData];
  	[worldsAndPlayersOutlineView expandItem: newWorld];
  }
  
  [(NSObject *) contextInfo release];
}

- (void) worldSheetDidEndEditing: (NSWindow *) sheet returnCode: (int) returnCode contextInfo: (void *) contextInfo
{
  if (returnCode == MUEditOkay)
  {
    MUWorld *oldWorld = (MUWorld *) contextInfo;
    MUWorld *newWorld = [self worldFromSheetWithPlayers: [oldWorld players]];
  	BOOL isExpanded = [worldsAndPlayersOutlineView isItemExpanded: oldWorld];
  	
    // Update every profile that has this world.
    [self updateProfilesForWorld: oldWorld
                       withWorld: newWorld];
  	
  	// Actually replace the old world with the new one.
  	[[MUServices worldRegistry] replaceWorld: oldWorld withWorld: newWorld];
  	
  	[worldsAndPlayersOutlineView reloadData];
  	
  	if (isExpanded)
  		[worldsAndPlayersOutlineView expandItem: newWorld];
  }
}

@end

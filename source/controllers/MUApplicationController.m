//
// MUApplicationController.m
//
// Copyright (C) 2004 3James Software
//

#import "FontNameToDisplayNameTransformer.h"
#import "J3PortFormatter.h"
#import "MUApplicationController.h"
#import "MUConnectionWindowController.h"
#import "MUPlayer.h"

@interface MUApplicationController (Private)

- (IBAction) openConnection:(id)sender;
- (void) updateConnectionsMenu;

@end

#pragma mark -

@implementation MUApplicationController

+ (void) initialize
{
  NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
  NSMutableDictionary *initialValues = [NSMutableDictionary dictionary];
  NSValueTransformer *transformer = [[FontNameToDisplayNameTransformer alloc] init];

  [NSValueTransformer setValueTransformer:transformer forName:@"FontNameToDisplayNameTransformer"];
  
  NSData *archivedWhite = [NSArchiver archivedDataWithRootObject:[NSColor lightGrayColor]];
  NSData *archivedBlack = [NSArchiver archivedDataWithRootObject:[NSColor blackColor]];
  NSFont *fixedFont = [NSFont userFixedPitchFontOfSize:[NSFont smallSystemFontSize]];
  
  [defaults setObject:[NSArray array] forKey:MUPWorlds];
  
  [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
  
  [initialValues setObject:archivedBlack forKey:MUPBackgroundColor];
  [initialValues setObject:[fixedFont fontName] forKey:MUPFontName];
  [initialValues setObject:[NSNumber numberWithFloat:[fixedFont pointSize]] forKey:MUPFontSize];
  [initialValues setObject:archivedWhite forKey:MUPTextColor];
  
  [[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:initialValues];
  
  [[NSFontManager sharedFontManager] setAction:@selector(changeGlobalFont:)];
}

- (void) awakeFromNib
{
  J3PortFormatter *formatter = [[[J3PortFormatter alloc] init] autorelease];
  NSData *worldsData = [[NSUserDefaults standardUserDefaults] dataForKey:MUPWorlds];
  
  if (worldsData)
  {
    int i, worldsCount;
    
    [self setWorlds:[NSKeyedUnarchiver unarchiveObjectWithData:worldsData]];
    
    worldsCount = [[self worlds] count];
    
    for (i = 0; i < worldsCount; i++)
    {
      MUWorld *world = [worlds objectAtIndex:i];
      NSArray *players = [world players];
      int j, playersCount = [players count];
      
      for (j = 0; j < playersCount; j++)
      {
        [[players objectAtIndex:j] setWorld:world];
      }
    }
  }
  else
  {
    [self setWorlds:[NSArray array]];
  }

  connectionWindowControllers = [[NSMutableArray alloc] init];
  
  [[portColumn dataCell] setFormatter:formatter];
}

- (void) dealloc
{
  [connectionWindowControllers release];
  [worlds release];
}

#pragma mark -
#pragma mark Accessors

- (NSArray *) worlds
{
  return worlds;
}

- (void) setWorlds:(NSArray *)newWorlds
{
  NSArray *copy = [newWorlds copy];
  [worlds release];
  worlds = copy;
  
  [self updateConnectionsMenu];
}

#pragma mark -
#pragma mark Actions

- (IBAction) changeGlobalFont:(id)sender
{
  NSFontManager *fontManager = [NSFontManager sharedFontManager];
  NSFont *selectedFont = [fontManager selectedFont];
  NSFont *panelFont;
  NSNumber *fontSize;
  
  if (selectedFont == nil)
  {
    selectedFont = [NSFont systemFontOfSize:[NSFont systemFontSize]];
  }
  panelFont = [fontManager convertFont:selectedFont];
  
  fontSize = [NSNumber numberWithFloat:[panelFont pointSize]];	
  
  id currentPrefsValues = [[NSUserDefaultsController sharedUserDefaultsController] values];
  [currentPrefsValues setValue:[panelFont fontName] forKey:MUPFontName];
  [currentPrefsValues setValue:fontSize forKey:MUPFontSize];
}

- (IBAction) chooseNewFont:(id)sender
{
  NSDictionary *values = [[NSUserDefaultsController sharedUserDefaultsController] values];
  NSString *fontName = [values valueForKey:MUPFontName];
  int fontSize = [[values valueForKey:MUPFontSize] floatValue];
  NSFont *font = [NSFont fontWithName:fontName size:fontSize];
  
  if (font == nil)
  {
    font = [NSFont systemFontOfSize:[NSFont systemFontSize]];
  }
  
  [[NSFontManager sharedFontManager] setSelectedFont:font isMultiple:NO];
  [[NSFontManager sharedFontManager] orderFrontFontPanel:self];
}

- (IBAction) showPreferences:(id)sender
{
  [preferencesPanel makeKeyAndOrderFront:self];
}

- (IBAction) showProfiles:(id)sender
{
  [profilesPanel makeKeyAndOrderFront:self];
}

#pragma mark -
#pragma mark NSApplication delegate

- (NSApplicationTerminateReply) applicationShouldTerminate:(NSApplication *)app
{
  unsigned count = [connectionWindowControllers count];
  unsigned openConnections = 0;
  
  while (count--)
  {
    MUConnectionWindowController *controller = [connectionWindowControllers objectAtIndex:count];
    if (controller && [controller isConnected])
      openConnections++;
  }
  
  if (openConnections > 0)
  {
    NSAlert *alert;
    int choice;
    
    alert = [NSAlert alertWithMessageText:NSLocalizedString (MULConfirmQuitTitle, nil)
                            defaultButton:NSLocalizedString (MULOkay, nil)
                          alternateButton:NSLocalizedString (MULCancel, nil)
                              otherButton:nil
                informativeTextWithFormat:(openConnections == 1 ? NSLocalizedString (MULConfirmQuitMessageSingular, nil)
                                                                : NSLocalizedString (MULConfirmQuitMessagePlural, nil)),
      openConnections];
    
    choice = [alert runModal];
      
    if (choice == NSAlertAlternateReturn)
      return NSTerminateCancel;
  }
  
  return NSTerminateNow;
}

- (void) applicationWillTerminate:(NSNotification *)notification
{
  [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:worlds] forKey:MUPWorlds];
}

#pragma mark -
#pragma mark NSControl delegate

- (void) controlTextDidEndEditing:(NSNotification *)notification
{
  [self updateConnectionsMenu];
}

#pragma mark -
#pragma mark MUConnectionWindowController delegate

- (void) windowIsClosingForConnectionWindowController:(MUConnectionWindowController *)controller
{
  [controller retain];
  [connectionWindowControllers removeObject:controller];
  [controller autorelease];
}

@end

#pragma mark -

@implementation MUApplicationController (Private)

- (IBAction) openConnection:(id)sender
{
  MUWorld *world = [sender representedObject];
  MUConnectionWindowController *controller = [[MUConnectionWindowController alloc] initWithWorld:world];
  
  [controller setDelegate:self];
  
  [connectionWindowControllers addObject:controller];
  [controller showWindow:self];
  [controller connect:sender];
  [controller release];
}

- (IBAction) openConnectionAndLogin:(id)sender
{
  MUPlayer *player = [sender representedObject];
  MUWorld *world = [player world];
  MUConnectionWindowController *controller = [[MUConnectionWindowController alloc] initWithWorld:world player:player];
  
  [controller setDelegate:self];
  
  [connectionWindowControllers addObject:controller];
  [controller showWindow:self];
  [controller connect:sender];
  NSLog (@"Sending %@", [player loginString]);
  [controller sendString:[player loginString]];
  [controller release];
}

- (void) updateConnectionsMenu
{
  int i, worldsCount = [worlds count], menuCount = [openConnectionMenu numberOfItems];
  
  for (i = menuCount - 1; i >= 0; i--)
  {
    [openConnectionMenu removeItemAtIndex:i];
  }
  
  for (i = 0; i < worldsCount; i++)
  {
    MUWorld *world = [worlds objectAtIndex:i];
    NSArray *players = [world players];
    NSMenuItem *worldItem = [[NSMenuItem alloc] init];
    NSMenu *worldMenu = [[NSMenu alloc] initWithTitle:[world worldName]];
    NSMenuItem *connectItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString (MULConnectWithoutLogin, nil)
                                                         action:@selector(openConnection:)
                                                  keyEquivalent:@""];
    int j, playersCount = [players count];
    
    for (j = 0; j < playersCount; j++)
    {
      MUPlayer *player = [players objectAtIndex:j];
      NSMenuItem *playerItem = [[NSMenuItem alloc] initWithTitle:[player name]
                                                           action:@selector(openConnectionAndLogin:)
                                                    keyEquivalent:@""];
      [playerItem setTarget:self];
      [playerItem setRepresentedObject:player];
      [worldMenu addItem:playerItem];
      [playerItem release];
    }
    
    if (playersCount > 0)
    {
      [worldMenu addItem:[NSMenuItem separatorItem]];
    }
    
    [connectItem setTarget:self];
    [connectItem setRepresentedObject:world];
    [worldMenu addItem:connectItem];
    [worldItem setTitle:[world worldName]];
    [worldItem setSubmenu:worldMenu];
    [openConnectionMenu addItem:worldItem];
    [worldItem release];
    [worldMenu release];
    [connectItem release];
  }
}

@end

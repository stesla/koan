//
// MUApplicationController.m
//
// Copyright (C) 2004 3James Software
//

#import "FontNameToDisplayNameTransformer.h"
#import "MUApplicationController.h"
#import "MUConnectionWindowController.h"
#import "J3PortFormatter.h"

@interface MUApplicationController (Private)

- (IBAction) openConnection:(id)sender;
- (void) updateConnectionsMenu;

@end

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
  NSArray *prefsConnections = [[NSUserDefaults standardUserDefaults] objectForKey:MUPWorlds];
  NSMutableArray *array = [NSMutableArray array];
  J3PortFormatter *formatter = [[[J3PortFormatter alloc] init] autorelease];
  int i, connectionsCount = [prefsConnections count];
  
  connectionWindowControllers = [[NSMutableArray alloc] init];
  
  for (i = 0; i < connectionsCount; i++)
  {
    [array addObject:[MUWorld connectionWithDictionary:[prefsConnections objectAtIndex:i]]];
  }
  
  [[portColumn dataCell] setFormatter:formatter];
  
  [self setWorlds:array];
}

- (void) dealloc
{
  [connectionWindowControllers release];
  [worlds release];
}

// Accessors.

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

// Actions.

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

// Delegate methods for NSApplication.

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
  NSMutableArray *array = [NSMutableArray array];
  int i, worldsCount = [worlds count];
  int controllerCount = [connectionWindowControllers count];
  
  for (i = 0; i < worldsCount; i++)
  {
    [array addObject:[[worlds objectAtIndex:i] objectDictionary]];
  }
  
  [[NSUserDefaults standardUserDefaults] setObject:array forKey:MUPWorlds];
}

// Delegate methods for NSControl.

- (void) controlTextDidEndEditing:(NSNotification *)notification
{
  [self updateConnectionsMenu];
}

// Delegate methods for MUConnectionWindowController.

- (void) windowIsClosingForConnectionWindowController:(MUConnectionWindowController *)controller
{
  [controller retain];
  [connectionWindowControllers removeObject:controller];
  [controller autorelease];
}

@end

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

- (void) updateConnectionsMenu
{
  int i, worldsCount = [worlds count], menuCount = [openConnectionMenu numberOfItems];
  
  NSLog (@"Updating menu.");
  
  for (i = menuCount - 1; i >= 0; i--)
  {
    [openConnectionMenu removeItemAtIndex:i];
  }
  
  for (i = 0; i < worldsCount; i++)
  {
    MUWorld *world = [worlds objectAtIndex:i];
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:[world worldName]
                                                  action:@selector(openConnection:)
                                           keyEquivalent:@""];
    
    [item setTarget:self];
    [item setRepresentedObject:world];
    [openConnectionMenu addItem:item];
    [item release];
  }
}

@end

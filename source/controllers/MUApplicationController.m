//
// MUApplicationController.m
//
// Copyright (C) 2004 3James Software
//

#import "FontNameToDisplayNameTransformer.h"
#import "MUApplicationController.h"
#import "MUConnectionWindowController.h"
#import "MUPlayer.h"
#import "MUProfilesController.h"
#import "MUWorld.h"
#import "MUWorldRegistry.h"

@interface MUApplicationController (Private)

- (IBAction) openConnection:(id)sender;
- (void) updateConnectionsMenu:(NSNotification *)notification;

@end

#pragma mark -

@implementation MUApplicationController

+ (void) initialize
{
  NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
  NSMutableDictionary *initialValues = [NSMutableDictionary dictionary];
  NSValueTransformer *transformer = [[FontNameToDisplayNameTransformer alloc] init];

  [NSValueTransformer setValueTransformer:transformer forName:@"FontNameToDisplayNameTransformer"];
  
  NSData *archivedLightGray = [NSArchiver archivedDataWithRootObject:[NSColor lightGrayColor]];
  NSData *archivedBlack = [NSArchiver archivedDataWithRootObject:[NSColor blackColor]];
  NSFont *fixedFont = [NSFont userFixedPitchFontOfSize:[NSFont smallSystemFontSize]];
  
  [defaults setObject:[NSArray array] forKey:MUPWorlds];
  
  [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
  
  [initialValues setObject:archivedBlack forKey:MUPBackgroundColor];
  [initialValues setObject:[fixedFont fontName] forKey:MUPFontName];
  [initialValues setObject:[NSNumber numberWithFloat:[fixedFont pointSize]] forKey:MUPFontSize];
  [initialValues setObject:archivedLightGray forKey:MUPTextColor];
  
  [[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:initialValues];
  
  [[NSFontManager sharedFontManager] setAction:@selector(changeGlobalFont:)];
}

- (void) awakeFromNib
{
  connectionWindowControllers = [[NSMutableArray alloc] init];
  
  [self updateConnectionsMenu:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(updateConnectionsMenu:)
                                               name:MUWorldsUpdatedNotification
                                             object:nil];
}

- (void) dealloc
{
  [connectionWindowControllers release];
  [profilesController release];
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

- (IBAction) openBugsWebPage:(id)sender
{
  [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://bugs.3james.com/"]];
}

- (IBAction) showPreferences:(id)sender
{
  [preferencesPanel makeKeyAndOrderFront:self];
}

- (IBAction) showProfiles:(id)sender
{
  if (!profilesController)
  {
    profilesController = [[MUProfilesController alloc] init];
  }
  
  if (profilesController)
  {
    [profilesController showWindow:self];
  }
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
  [[MUWorldRegistry sharedRegistry] saveWorlds];
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
  MUConnectionWindowController *controller;
  MUWorld *world = nil;
  MUPlayer *player = nil;
  id object = [sender representedObject];
  
  if ([object class] == [MUWorld class])
  {
    world = (MUWorld *) object;
    controller = [[MUConnectionWindowController alloc] initWithWorld:world];
  }
  else if ([object class] == [MUPlayer class])
  {
    player = (MUPlayer *) object;
    world = [player world];
    controller = [[MUConnectionWindowController alloc] initWithWorld:world player:player];
  }
  
  [controller setDelegate:self];
  
  [connectionWindowControllers addObject:controller];
  [controller showWindow:self];
  [controller connect:sender];
  [controller release];
}

- (void) updateConnectionsMenu:(NSNotification *)notification
{
  MUWorldRegistry *registry = [MUWorldRegistry sharedRegistry];
  int i, worldsCount = [registry count], menuCount = [openConnectionMenu numberOfItems];
  
  for (i = menuCount - 1; i >= 0; i--)
  {
    [openConnectionMenu removeItemAtIndex:i];
  }
  
  for (i = 0; i < worldsCount; i++)
  {
    MUWorld *world = [registry worldAtIndex:i];
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
                                                           action:@selector(openConnection:)
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

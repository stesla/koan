//
// MUApplicationController.m
//
// Copyright (c) 2004, 2005 3James Software
//

#import "FontNameToDisplayNameTransformer.h"
#import "MUApplicationController.h"
#import "MUConnectionWindowController.h"
#import "MUGrowlService.h"
#import "MUPlayer.h"
#import "MUProfilesController.h"
#import "MUServices.h"
#import "MUWorld.h"

@interface MUApplicationController (Private)

- (IBAction) openConnection:(id)sender;
- (void) handleWorldsUpdatedNotification:(NSNotification *)notification;
- (void) rebuildConnectionsMenuWithAutoconnect:(BOOL)autoconnect;
- (void) updateApplicationBadge;

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
  
  [MUGrowlService initializeGrowl];
}

- (void) awakeFromNib
{
  [MUServices profileRegistry];
  [MUServices worldRegistry];
  
  connectionWindowControllers = [[NSMutableArray alloc] init];
  
  [self rebuildConnectionsMenuWithAutoconnect:YES];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(handleWorldsUpdatedNotification:)
                                               name:MUWorldsUpdatedNotification
                                             object:nil];
  
  unreadCount = 0;
  [self updateApplicationBadge];
}

- (void) dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:nil];
  [connectionWindowControllers release];
  [profilesController release];
  [super dealloc];
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

- (void) applicationDidBecomeActive:(NSNotification *)notification
{
  unreadCount = 0;
  [self updateApplicationBadge];
}

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
  unreadCount = 0;
  [self updateApplicationBadge];
  
  [[MUServices worldRegistry] saveWorlds];
  [[MUServices profileRegistry] saveProfiles];
}

#pragma mark -
#pragma mark MUConnectionWindowController delegate

- (void) connectionWindowControllerWillClose:(NSNotification *)notification
{
  MUConnectionWindowController *controller = [notification object];
  
  [controller retain];
  [connectionWindowControllers removeObject:controller];
  [controller autorelease];
}

- (void) connectionWindowControllerDidReceiveText:(NSNotification *)notification
{
  if (![NSApp isActive])
  {
    [NSApp requestUserAttention:NSInformationalRequest];
    
    unreadCount++;
    [self updateApplicationBadge];
  }
}

@end

#pragma mark -

@implementation MUApplicationController (Private)

- (void) handleWorldsUpdatedNotification:(NSNotification *)notification
{
  [self rebuildConnectionsMenuWithAutoconnect:NO];
}

- (IBAction) openConnection:(id)sender
{
  MUConnectionWindowController *controller;
  MUProfile *profile = [sender representedObject];
  controller = [[MUConnectionWindowController alloc] initWithProfile:profile];

  [controller setDelegate:self];
  
  [connectionWindowControllers addObject:controller];
  [controller showWindow:self];
  [controller connect:sender];
  [controller release];
}

- (void) rebuildConnectionsMenuWithAutoconnect:(BOOL)autoconnect
{
  MUWorldRegistry *registry = [MUServices worldRegistry];
  MUProfileRegistry *profiles = [MUServices profileRegistry];
  int i, worldsCount = [registry count], menuCount = [openConnectionMenu numberOfItems];
  
  for (i = menuCount - 1; i >= 0; i--)
  {
    [openConnectionMenu removeItemAtIndex:i];
  }
  
  for (i = 0; i < worldsCount; i++)
  {
    MUWorld *world = [registry worldAtIndex:i];
    MUProfile *profile = [profiles profileForWorld:world];
    NSArray *players = [world players];
    NSMenuItem *worldItem = [[NSMenuItem alloc] init];
    NSMenu *worldMenu = [[NSMenu alloc] initWithTitle:[world worldName]];
    NSMenuItem *connectItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString (MULConnectWithoutLogin, nil)
                                                         action:@selector(openConnection:)
                                                  keyEquivalent:@""];
    int j, playersCount = [players count];
    
    [connectItem setTarget:self];
    [connectItem setRepresentedObject:profile];

    if (autoconnect)
    {
      [profile setWorld:world];
      if ([profile autoconnect])
        [self openConnection:connectItem];
    }
    
    for (j = 0; j < playersCount; j++)
    {
      MUPlayer *player = [players objectAtIndex:j];
      profile = [profiles profileForWorld:world player:player];
    
      NSMenuItem *playerItem = [[NSMenuItem alloc] initWithTitle:[player name]
                                                          action:@selector(openConnection:)
                                                   keyEquivalent:@""];
      [playerItem setTarget:self];
      [playerItem setRepresentedObject:profile];
      
      if (autoconnect)
      {
        [profile setWorld:world];
        [profile setPlayer:player];
        if ([profile autoconnect])
          [self openConnection:playerItem];
      }
      
      [worldMenu addItem:playerItem];
      [playerItem release];
    }
    
    if (playersCount > 0)
    {
      [worldMenu addItem:[NSMenuItem separatorItem]];
    }
    
    [worldMenu addItem:connectItem];
    [worldItem setTitle:[world worldName]];
    [worldItem setSubmenu:worldMenu];
    [openConnectionMenu addItem:worldItem];
    [worldItem release];
    [worldMenu release];
    [connectItem release];
  }
}

- (void) updateApplicationBadge
{
  NSDictionary *attributeDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
    [NSColor whiteColor], NSForegroundColorAttributeName,
    [NSFont fontWithName:@"Helvetica Bold" size:25.0], NSFontAttributeName,
    nil];
  NSAttributedString *unreadCountString =
    [NSAttributedString attributedStringWithString:[NSString stringWithFormat:@"%@", [NSNumber numberWithUnsignedInt:unreadCount]]
                                        attributes:attributeDictionary];
  NSImage *appImage, *newAppImage, *badgeImage;
  NSSize newAppImageSize, badgeImageSize;
  NSPoint unreadCountStringLocationPoint;
  
  appImage = [NSImage imageNamed:@"NSApplicationIcon"];
  
  newAppImage = [[NSImage alloc] initWithSize:[appImage size]];
  newAppImageSize = [newAppImage size];
  
  [newAppImage lockFocus];
  
  [appImage drawInRect:NSMakeRect (0, 0, newAppImageSize.width, newAppImageSize.height)
              fromRect:NSMakeRect (0, 0, [appImage size].width, [appImage size].height)
             operation:NSCompositeCopy
              fraction:1.0];
  
  if (unreadCount > 0)
  {
    if (unreadCount < 100)
      badgeImage = [NSImage imageNamed:@"badge-1-2"];
    else if (unreadCount < 1000)
      badgeImage = [NSImage imageNamed:@"badge-3"];
    else if (unreadCount < 10000)
      badgeImage = [NSImage imageNamed:@"badge-4"];
    else
      badgeImage = [NSImage imageNamed:@"badge-5"];
    
    
    badgeImageSize = [badgeImage size];
    
    [badgeImage drawInRect:NSMakeRect (newAppImageSize.width - badgeImageSize.width,
                                       newAppImageSize.height - badgeImageSize.height,
                                       badgeImageSize.width,
                                       badgeImageSize.height)
                  fromRect:NSMakeRect (0, 0, badgeImageSize.width, badgeImageSize.height)
                 operation:NSCompositeSourceOver
                  fraction:1.0];
    
    if (unreadCount < 10)
    {
      unreadCountStringLocationPoint = NSMakePoint (newAppImageSize.width - badgeImageSize.width + 19.0,
                                                    newAppImageSize.height - badgeImageSize.height + 12.0);
    }
    else if (unreadCount < 100)
    {
      unreadCountStringLocationPoint = NSMakePoint (newAppImageSize.width - badgeImageSize.width + 12.0,
                                                    newAppImageSize.height - badgeImageSize.height + 12.0);
    }
    else if (unreadCount < 1000)
    {
      unreadCountStringLocationPoint = NSMakePoint (newAppImageSize.width - badgeImageSize.width + 14.0,
                                                    newAppImageSize.height - badgeImageSize.height + 12.0);
    }
    else if (unreadCount < 10000)
    {
      unreadCountStringLocationPoint = NSMakePoint (newAppImageSize.width - badgeImageSize.width + 12.0,
                                                    newAppImageSize.height - badgeImageSize.height + 12.0);
    }
    else
    {
      unreadCountStringLocationPoint = NSMakePoint (newAppImageSize.width - badgeImageSize.width + 10.0,
                                                    newAppImageSize.height - badgeImageSize.height + 12.0);
    }
    
    
    [unreadCountString drawAtPoint:unreadCountStringLocationPoint];
  }
  
  [newAppImage unlockFocus];
  
  [NSApp setApplicationIconImage:newAppImage];
  [newAppImage release];
}

@end

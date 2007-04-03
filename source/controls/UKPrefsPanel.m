//
// UKPrefsPanel.h
//
// Copyright (c) 2003-2005 M. Uli Kusterer. All rights reserved.
//
// License:
//
//   You may redistribute, modify, use in commercial products free of charge,
//   however distributing modified copies requires that you clearly mark them
//   as having been modified by you, while maintaining the original markings
//   and copyrights. I don't like getting bug reports about code I wasn't
//   involved in.
//
//   I'd also appreciate if you gave credit in your app's about screen or a
//   similar place. A simple "Thanks to M. Uli Kusterer" is quite sufficient.
//   Also, I rarely turn down any postcards, gifts, complementary copies of
//   applications etc.
//
// Modified version by Tyler Berry.
// Copyright (c) 2007 3James Software
//

#import "UKPrefsPanel.h"

@interface UKPrefsPanel (Private)

- (IBAction) changePanes: (id) sender;
- (void) mapTabsToToolbar;

@end

#pragma mark -

@implementation UKPrefsPanel

- (id) init
{
  if (![super init])
    return nil;
  
  tabView = nil;
  itemsList = [[NSMutableDictionary alloc] init];
  baseWindowName = [@"" copy];
  autosaveName = [@"com.ulikusterer" copy];
  
  return self;
}

- (void) dealloc
{
  [itemsList release];
  [baseWindowName release];
  [autosaveName release];
  [super dealloc];
}

- (void) awakeFromNib
{
  NSString *windowTitle = [[tabView window] title];
  if ([windowTitle length] > 0)
  {
  	[baseWindowName release];
  	baseWindowName = [[NSString stringWithFormat: @"%@ : ", windowTitle] retain];
  }
  
  [self setAutosaveName: [[tabView window] frameAutosaveName]];
  
  NSString *key = [NSString stringWithFormat: @"%@.prefspanel.recentpage", autosaveName];
  int tabIndex = [[NSUserDefaults standardUserDefaults] integerForKey: key];
  [tabView selectTabViewItemAtIndex: tabIndex];
  
  [self mapTabsToToolbar];
}

#pragma mark -
#pragma mark Accessors

- (NSTabView *) tabView
{
  return tabView;
}

- (void) setTabView: (NSTabView *) view
{
  tabView = view;
}

- (NSString *) autosaveName
{
  return autosaveName;
}

- (void) setAutosaveName: (NSString *) name
{
  if (autosaveName == name)
    return;
  [autosaveName release];
  autosaveName = [name retain];
}

#pragma mark -
#pragma mark Actions

- (IBAction) orderFrontPrefsPanel: (id) sender
{
  [[tabView window] makeKeyAndOrderFront: sender];
}

#pragma mark -
#pragma mark NSToolbar delegate

- (NSToolbarItem *) toolbar: (NSToolbar *) toolbar
      itemForItemIdentifier: (NSString *) itemIdentifier
  willBeInsertedIntoToolbar: (BOOL) willBeInserted
{
  NSToolbarItem *toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier: itemIdentifier] autorelease];
  NSString *itemLabel = [itemsList objectForKey: itemIdentifier];
  
  if (itemLabel)
  {
  	[toolbarItem setLabel: itemLabel];
  	[toolbarItem setPaletteLabel: itemLabel];
  	[toolbarItem setTag: [tabView indexOfTabViewItemWithIdentifier: itemIdentifier]];
  	
  	[toolbarItem setToolTip: itemLabel];
  	[toolbarItem setImage: [NSImage imageNamed: itemIdentifier]];
  	
  	[toolbarItem setTarget: self];
  	[toolbarItem setAction: @selector (changePanes:)];
  }
  else
  	toolbarItem = nil;
  
  return toolbarItem;
}

#if MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_3
- (NSArray *) toolbarSelectableItemIdentifiers: (NSToolbar *) toolbar
{
  return [itemsList allKeys];
}
#endif

- (NSArray *) toolbarDefaultItemIdentifiers: (NSToolbar *) toolbar
{
  NSMutableArray *defaultItems = [NSMutableArray array];
  
  for (unsigned i = 0; i < (unsigned) [tabView numberOfTabViewItems]; i++)
  {
  	[defaultItems addObject: [[tabView tabViewItemAtIndex: i] identifier]];
  }
  
  return defaultItems;
}

- (NSArray*) toolbarAllowedItemIdentifiers: (NSToolbar *) toolbar
{
  NSMutableArray *allowedItems = [[itemsList allKeys] mutableCopy];
  
  [allowedItems addObjectsFromArray: [NSArray arrayWithObjects:
    NSToolbarSeparatorItemIdentifier,
    NSToolbarSpaceItemIdentifier,
    NSToolbarFlexibleSpaceItemIdentifier,
    NSToolbarCustomizeToolbarItemIdentifier,
    nil]];
  
  return allowedItems;
}

@end

#pragma mark -

@implementation UKPrefsPanel (Private)

- (IBAction) changePanes: (id) sender
{
  [tabView selectTabViewItemAtIndex: [sender tag]];
  [[tabView window] setTitle: [baseWindowName stringByAppendingString: [sender label]]];
  
  NSString *key = [NSString stringWithFormat:  @"%@.prefspanel.recentpage", autosaveName];
  [[NSUserDefaults standardUserDefaults] setInteger: [sender tag] forKey: key];
}

- (void) mapTabsToToolbar
{
  NSToolbar *toolbar = [[tabView window] toolbar];
  
  if (!toolbar)
  	toolbar = [[[NSToolbar alloc] initWithIdentifier: [NSString stringWithFormat: @"%@.prefspanel.toolbar", autosaveName]] autorelease];
  
  [toolbar setAllowsUserCustomization: YES];
  [toolbar setAutosavesConfiguration: YES];
  [toolbar setDisplayMode: NSToolbarDisplayModeIconAndLabel];
  
  [itemsList removeAllObjects];
  
  for (unsigned i = 0; i < (unsigned) [tabView numberOfTabViewItems]; i++)
  {
  	[itemsList setObject: [[tabView tabViewItemAtIndex: i] label]
                  forKey: [[tabView tabViewItemAtIndex: i] identifier]];
  }
  
  [toolbar setDelegate: self];
  
  [[tabView window] setToolbar: toolbar];
  
  NSTabViewItem	*currentTab = [tabView selectedTabViewItem];
  if (currentTab == nil)
  	currentTab = [tabView tabViewItemAtIndex: 0];
  
  [[tabView window] setTitle: [baseWindowName stringByAppendingString: [currentTab label]]];
  
#if MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_3
  if ([toolbar respondsToSelector: @selector (setSelectedItemIdentifier:)])
  	[toolbar setSelectedItemIdentifier: [currentTab identifier]];
#endif
}

@end

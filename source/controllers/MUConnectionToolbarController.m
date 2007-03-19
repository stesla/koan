//
// MUConnectionToolbarController.m
//
// Copyright (c) 2004, 2005 3James Software
//

#import "MUConnectionToolbarController.h"

@implementation MUConnectionToolbarController

- (void) awakeFromNib
{
  toolbar = [[NSToolbar alloc] initWithIdentifier:@"connectionWindowToolbar"];
	
  [toolbar setDelegate:self];
  [toolbar setAllowsUserCustomization:YES];
  [toolbar setAutosavesConfiguration:YES];
	
  [window setToolbar:toolbar];
	
	[toolbar release];
}

#pragma mark -
#pragma mark NSToolbar delegate

- (NSToolbarItem *) toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag
{
  NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
  
  if ([itemIdentifier isEqualToString:MUGoToURLToolbarItem])
  {
    [item setLabel:_(MULGoToURL)];
    [item setPaletteLabel:_(MULGoToURL)];
    [item setImage:nil];
    [item setTarget:windowController];
    [item setAction:@selector(goToWorldURL:)];
  }
  
  return [item autorelease];
}

- (NSArray *) toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar
{
  return [NSArray arrayWithObjects:
    NSToolbarFlexibleSpaceItemIdentifier,
    NSToolbarCustomizeToolbarItemIdentifier,
    nil];
}

- (NSArray *) toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar
{
  return [NSArray arrayWithObjects:
    NSToolbarSeparatorItemIdentifier,
    NSToolbarSpaceItemIdentifier,
    NSToolbarFlexibleSpaceItemIdentifier,
    NSToolbarCustomizeToolbarItemIdentifier,
    NSToolbarShowColorsItemIdentifier,
    NSToolbarShowFontsItemIdentifier,
    NSToolbarPrintItemIdentifier,
    MUGoToURLToolbarItem,
    nil];
}

@end

//
// MUConnectionToolbarController.m
//
// Copyright (C) 2004 3James Software
//

#import "MUConnectionToolbarController.h"

@implementation MUConnectionToolbarController

- (void) awakeFromNib
{
  toolbar = [[NSToolbar alloc] initWithIdentifier:@"connectionWindowToolbar"];
  [toolbar setDelegate:self];
  [toolbar setAllowsUserCustomization:YES];
  [toolbar setAutosavesConfiguration:YES];
  
  [window setToolbar:[toolbar autorelease]];
}

// Implementation of NSToolbar delegate methods.

- (NSToolbarItem *) toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag
{
  NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
  
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
    nil];
}

@end

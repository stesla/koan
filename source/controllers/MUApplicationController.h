//
// MUApplicationController.h
//
// Copyright (C) 2004 3James Software
//

#import <Cocoa/Cocoa.h>

@interface MUApplicationController : NSObject
{
  IBOutlet NSPanel *preferencePanel;
  IBOutlet NSMenu *openConnectionMenu;
  IBOutlet NSTableColumn *portColumn;
  
  NSMutableArray *connectionWindowControllers;
  NSArray *worlds;
}

- (NSArray *) worlds;
- (void) setWorlds:(NSArray *)newWorlds;

- (IBAction) changeGlobalFont:(id)sender;
- (IBAction) chooseNewFont:(id)sender;
- (IBAction) showPreferences:(id)sender;

@end

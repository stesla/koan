//
// MUConnectionWindowController.h
//
// Copyright (C) 2004 3James Software
//

#import <Cocoa/Cocoa.h>
#import <J3Terminal/J3TelnetConnection.h>

#import "MUWorld.h"
#import "MUFilter.h"
#import "MUHistoryRing.h"

@interface MUConnectionWindowController : NSWindowController
{
  IBOutlet NSTextView *receivedTextView;
  IBOutlet NSTextView *inputView;
  IBOutlet id delegate;
  
  MUWorld *world;
  J3TelnetConnection *telnetConnection;
  
  MUFilterQueue *filterQueue;
  MUHistoryRing *historyRing;
}

// Designated initializer.
- (id) initWithWorld:(MUWorld *)world;

- (BOOL) isConnected;

- (id) delegate;
- (void) setDelegate:(id)delegate;

- (IBAction) connect:(id)sender;
- (IBAction) disconnect:(id)sender;
- (IBAction) writeLine:(id)sender;

- (IBAction) nextCommand:(id)sender;
- (IBAction) previousCommand:(id)sender;

@end

@interface NSObject (MUConnectionWindowControllerDelegate)

- (void) windowIsClosingForConnectionWindowController:(MUConnectionWindowController *)controller;

@end

//
// MUConnectionWindowController.h
//
// Copyright (c) 2007 3James Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <RBSplitView/RBSplitView.h>

#import "J3Filter.h"
#import "MUDisplayTextView.h"
#import "J3HistoryRing.h"
#import "MUProfile.h"

@interface MUConnectionWindowController : NSWindowController <J3TelnetConnectionDelegate>
{
  IBOutlet MUDisplayTextView *receivedTextView;
  IBOutlet NSTextView *inputView;
  IBOutlet RBSplitView *splitView;
  
  id delegate;
  
  MUProfile *profile;
  J3TelnetConnection *telnetConnection;
  
  BOOL currentlySearching;
  
  NSTimer *pingTimer;
  J3FilterQueue *filterQueue;
  J3HistoryRing *historyRing;
}

// Designated initializer.
- (id) initWithProfile: (MUProfile *) newProfile;

- (id) initWithWorld: (MUWorld *) newWorld player: (MUPlayer *) newPlayer;
- (id) initWithWorld: (MUWorld *) newWorld;

- (id) delegate;
- (void) setDelegate: (id) delegate;

- (void) confirmClose: (SEL) callback;
- (IBAction) connect: (id) sender;
- (IBAction) disconnect: (id) sender;
- (IBAction) goToWorldURL: (id) sender;
- (BOOL) isConnected;
- (IBAction) nextCommand: (id) sender;
- (IBAction) previousCommand: (id) sender;
- (IBAction) sendInputText: (id) sender;

@end

@interface NSObject (MUConnectionWindowControllerDelegate)

- (void) connectionWindowControllerWillClose: (NSNotification *) notification;
- (void) connectionWindowControllerDidReceiveText: (NSNotification *) notification;

@end

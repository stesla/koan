//
// MUConnectionWindowController.h
//
// Copyright (c) 2010 3James Software.
//

#import <Cocoa/Cocoa.h>

#import "J3Filter.h"
#import "J3HistoryRing.h"
#import "MUDisplayTextView.h"
#import "MUProfile.h"
#import "RBSplitView.h"

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
- (IBAction) nextCommand: (id) sender;
- (IBAction) previousCommand: (id) sender;
- (IBAction) sendInputText: (id) sender;

- (BOOL) isConnectedOrConnecting;

@end

#pragma mark -

@interface NSObject (MUConnectionWindowControllerDelegate)

- (void) connectionWindowControllerWillClose: (NSNotification *) notification;
- (void) connectionWindowControllerDidReceiveText: (NSNotification *) notification;

@end

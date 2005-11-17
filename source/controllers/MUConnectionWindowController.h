//
// MUConnectionWindowController.h
//
// Copyright (c) 2004, 2005 3James Software
//

#import <Cocoa/Cocoa.h>
#import <RBSplitView/RBSplitView.h>

#import "J3LineBuffer.h"
#import "J3Socket.h"
#import "J3Filter.h"
#import "MUDisplayTextView.h"
#import "J3HistoryRing.h"
#import "MUProfile.h"

@interface MUConnectionWindowController : NSWindowController <J3LineBufferDelegate, J3SocketDelegate>
{
  IBOutlet MUDisplayTextView *receivedTextView;
  IBOutlet NSTextView *inputView;
  IBOutlet RBSplitView *splitView;
  IBOutlet id delegate;
  
  MUProfile *profile;
  J3NewTelnetConnection *telnetConnection;
    
  BOOL currentlySearching;
  
  NSTimer *pingTimer;
  J3FilterQueue *filterQueue;
  J3HistoryRing *historyRing;
}

// Designated initializer.
- (id) initWithProfile:(MUProfile *)newProfile;

- (id) initWithWorld:(MUWorld *)newWorld player:(MUPlayer *)newPlayer;
- (id) initWithWorld:(MUWorld *)newWorld;

- (BOOL) isConnected;

- (id) delegate;
- (void) setDelegate:(id)delegate;

- (IBAction) connect:(id)sender;
- (IBAction) disconnect:(id)sender;
- (IBAction) goToWorldURL:(id)sender;
- (IBAction) sendInputText:(id)sender;

- (IBAction) nextCommand:(id)sender;
- (IBAction) previousCommand:(id)sender;

@end

@interface NSObject (MUConnectionWindowControllerDelegate)

- (void) connectionWindowControllerWillClose:(NSNotification *)notification;
- (void) connectionWindowControllerDidReceiveText:(NSNotification *)notification;

@end

//
// MUConnectionWindowController.h
//
// Copyright (C) 2004 3James Software
//

#import <Cocoa/Cocoa.h>
#import <J3Terminal/J3TelnetConnection.h>

#import "J3Filter.h"
#import "MUForwardingTextView.h"
#import "J3HistoryRing.h"
#import "MUProfile.h"

@interface MUConnectionWindowController : NSWindowController
{
  IBOutlet MUForwardingTextView *receivedTextView;
  IBOutlet NSTextView *inputView;
  IBOutlet id delegate;
  
  MUProfile *profile;
  J3TelnetConnection *telnetConnection;
  
  BOOL autoLoggedIn;
  
  J3FilterQueue *filterQueue;
  J3HistoryRing *historyRing;
}

// Designated initializer.
- (id) initWithProfile:(MUProfile*)newProfile;

- (id) initWithWorld:(MUWorld *)newWorld player:(MUPlayer *)newPlayer;
- (id) initWithWorld:(MUWorld *)newWorld;

- (BOOL) isConnected;

- (id) delegate;
- (void) setDelegate:(id)delegate;

- (IBAction) connect:(id)sender;
- (IBAction) disconnect:(id)sender;
- (IBAction) sendInputText:(id)sender;

- (IBAction) nextCommand:(id)sender;
- (IBAction) previousCommand:(id)sender;

@end

@interface NSObject (MUConnectionWindowControllerDelegate)

- (void) connectionWindowControllerWillClose:(NSNotification *)notification;
- (void) connectionWindowControllerDidReceiveText:(NSNotification *)notification;

@end

//
// MUConnectionWindowController.h
//
// Copyright (C) 2004 3James Software
//

#import <Cocoa/Cocoa.h>
#import <J3Terminal/J3TelnetConnection.h>

#import "MUConnectionSpec.h"
#import "MUFilter.h"
#import "MUHistoryRing.h"

@interface MUConnectionWindowController : NSWindowController
{
  IBOutlet NSTextView *receivedTextView;
  IBOutlet NSTextView *inputView;
  
  MUConnectionSpec *connectionSpec;
  J3TelnetConnection *telnetConnection;
  
  MUFilterQueue *filterQueue;
  MUHistoryRing *historyRing;
}

// Designated initializer.
- (id) initWithConnectionSpec:(MUConnectionSpec *)newConnectionSpec;

- (BOOL) isConnected;

- (IBAction) connect:(id)sender;
- (IBAction) disconnect:(id)sender;
- (IBAction) writeLine:(id)sender;

- (IBAction) nextCommand:(id)sender;
- (IBAction) previousCommand:(id)sender;

@end

//
//  J3TelnetOption.h
//  Koan
//
//  Created by Samuel Tesla on 4/10/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// This implements the Telnet Q Method: http://rfc.net/rfc1143.html

typedef enum J3TelnetQ {
  J3TelnetQNo,
  J3TelnetQYes,
  J3TelnetQWantNoEmpty,
  J3TelnetQWantNoOpposite,
  J3TelnetQWantYesEmpty,
  J3TelnetQWantYesOpposite
} J3TelnetQState;

@protocol J3TelnetOptionDelegate;

@interface J3TelnetOption : NSObject 
{
  id <J3TelnetOptionDelegate> delegate;
  int option;
  J3TelnetQState him;
  J3TelnetQState us;
  BOOL heIsAllowed;
  BOOL weAreAllowed;
}

- (id) initWithOption: (int) option delegate: (id <J3TelnetOptionDelegate>) object;

// Negotiation we respond to
- (void) receivedDo;
- (void) receivedDont;
- (void) receivedWill;
- (void) receivedWont;

// Negotiation we start
- (void) disableHim;
- (void) disableUs;
- (void) enableHim;
- (void) enableUs;

// Determining if options should be or are enabled
- (BOOL) heIsYes;
- (void) heIsAllowedToUse: (BOOL) value;
- (BOOL) weAreYes;
- (void) weAreAllowedToUse: (BOOL) value;

@end

@protocol J3TelnetOptionDelegate

- (void) do: (uint8_t) option;
- (void) dont: (uint8_t) option;
- (void) will: (uint8_t) option;
- (void) wont: (uint8_t) option;

@end

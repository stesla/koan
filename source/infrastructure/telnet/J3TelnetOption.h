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
  BOOL shouldEnable;
}

- (id) initWithOption: (int) option delegate: (id <J3TelnetOptionDelegate>) object;

- (void) setShouldEnable: (BOOL) value;

// Options on the other end
- (void) receivedDo;
- (void) receivedDont;
- (void) receivedWill;
- (void) receivedWont;

// These are for testing purposes.  Normal users of this object should not
// even be interested in calling these methods.
- (J3TelnetQState) him;
- (void) setHim: (J3TelnetQState) state;
- (J3TelnetQState) us;
- (void) setUs: (J3TelnetQState) state;

@end

@protocol J3TelnetOptionDelegate

- (void) do: (uint8_t) option;
- (void) dont: (uint8_t) option;
- (void) will: (uint8_t) option;
- (void) wont: (uint8_t) option;

@end

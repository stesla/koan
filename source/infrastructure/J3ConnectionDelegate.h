//
// J3ConnectionDelegate.h
//
// Copyright (c) 2007 3James Software.
//

#import <Cocoa/Cocoa.h>


extern NSString *J3ConnectionDidConnectNotification;
extern NSString *J3ConnectionIsConnectingNotification;
extern NSString *J3ConnectionWasClosedByClientNotification;
extern NSString *J3ConnectionWasClosedByServerNotification;
extern NSString *J3ConnectionWasClosedWithErrorNotification;
extern NSString *J3ConnectionErrorMessageKey;

@protocol J3ConnectionDelegate

- (void) connectionDidConnect: (NSNotification *) notification;
- (void) connectionIsConnecting: (NSNotification *) notification;
- (void) connectionWasClosedByClient: (NSNotification *) notification;
- (void) connectionWasClosedByServer: (NSNotification *) notification;
- (void) connectionWasClosedWithError: (NSNotification *) notification;

@end

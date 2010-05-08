//
// J3Connection.h
//
// Copyright (c) 2010 3James Software.
//

#import <Cocoa/Cocoa.h>

typedef enum J3ConnectionStatus
{
  J3ConnectionStatusNotConnected,
  J3ConnectionStatusConnecting,
  J3ConnectionStatusConnected,
  J3ConnectionStatusClosed
} J3ConnectionStatus;

#pragma mark -

@interface J3Connection : NSObject
{
  J3ConnectionStatus status;
}

- (void) close;
- (BOOL) isClosed;
- (BOOL) isConnected;
- (BOOL) isConnecting;
- (void) open;

@end

#pragma mark -

@interface J3Connection (Protected)

- (void) setStatusConnected;
- (void) setStatusConnecting;
- (void) setStatusClosedByClient;
- (void) setStatusClosedByServer;
- (void) setStatusClosedWithError: (NSString *) error;

@end

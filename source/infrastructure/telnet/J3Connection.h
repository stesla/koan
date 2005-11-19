//
// J3Connection.h
//
// Copyright (c) 2005 3James Software
//

@protocol J3Connection

- (void) close;
- (BOOL) isClosed;
- (BOOL) isConnected;
- (void) open;
- (void) poll;

@end

@protocol J3ConnectionDelegate

- (void) connectionIsConnecting:(id <J3Connection>)socket;
- (void) connectionIsConnected:(id <J3Connection>)socket;
- (void) connectionIsClosedByClient:(id <J3Connection>)socket;
- (void) connectionIsClosedByServer:(id <J3Connection>)socket;
- (void) connectionIsClosed:(id <J3Connection>)socket withError:(NSString *)errorMessage;

@end

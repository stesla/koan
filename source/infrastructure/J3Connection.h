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

- (void) connectionIsConnecting:(id <J3Connection>)connection;
- (void) connectionIsConnected:(id <J3Connection>)connection;
- (void) connectionWasClosedByClient:(id <J3Connection>)connection;
- (void) connectionWasClosedByServer:(id <J3Connection>)connection;
- (void) connectionWasClosed:(id <J3Connection>)connection withError:(NSString *)errorMessage;

@end

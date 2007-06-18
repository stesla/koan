//
// J3Connection.m
//
// Copyright (c) 2007 3James Software.
//


#import "J3Connection.h"

NSString *J3ConnectionDidConnectNotification = @"J3ConnectionDidConnectNotification";
NSString *J3ConnectionIsConnectingNotification = @"J3ConnectionIsConnectingNotification";
NSString *J3ConnectionWasClosedByClientNotification = @"J3ConnectionWasClosedByClientNotification";
NSString *J3ConnectionWasClosedByServerNotification = @"J3ConnectionWasClosedByServerNotification";
NSString *J3ConnectionWasClosedWithErrorNotification = @"J3ConnectionWasClosedWithErrorNotification";
NSString *J3ConnectionErrorMessageKey = @"J3ConnectionErrorMessageKey";

@interface J3Connection (Private)

- (void) removeNotificationFromDelegate: (NSString *) name selector: (SEL) selector andAddToObject: (id) object;

@end

#pragma mark -

@implementation J3Connection

- (void) close
{
}

- (id) init
{
  if (![super init])
    return nil;
  status = J3ConnectionStatusNotConnected;
  return self;
}

- (BOOL) isClosed
{
  return status == J3ConnectionStatusClosed;
}

- (BOOL) isConnected
{
  return status == J3ConnectionStatusConnected;
}

- (BOOL) isConnecting
{
  return status == J3ConnectionStatusConnecting;
}

- (void) open
{
}

- (void) setDelegate: (id <J3ConnectionDelegate>) object
{
  if (delegate == object)
    return;
  
  [self removeNotificationFromDelegate: J3ConnectionDidConnectNotification 
                              selector: @selector(connectionDidConnect:) 
                        andAddToObject: object];
  [self removeNotificationFromDelegate: J3ConnectionIsConnectingNotification 
                              selector: @selector(connectionIsConnecting:) 
                        andAddToObject: object];
  [self removeNotificationFromDelegate: J3ConnectionWasClosedByClientNotification 
                              selector: @selector(connectionWasClosedByClient:) 
                        andAddToObject: object];
  [self removeNotificationFromDelegate: J3ConnectionWasClosedByServerNotification 
                              selector: @selector(connectionWasClosedByServer:) 
                        andAddToObject: object];
  [self removeNotificationFromDelegate: J3ConnectionWasClosedWithErrorNotification 
                              selector: @selector(connectionWasClosedWithError:) 
                        andAddToObject: object];
  
  delegate = object;
}

- (void) setStatusConnected
{
  status = J3ConnectionStatusConnected;
  [[NSNotificationCenter defaultCenter] postNotificationName: J3ConnectionDidConnectNotification
                                                      object: self];
}

- (void) setStatusConnecting
{
  status = J3ConnectionStatusConnecting;
  [[NSNotificationCenter defaultCenter] postNotificationName: J3ConnectionIsConnectingNotification
                                                      object: self];
}

- (void) setStatusClosedByClient
{
  status = J3ConnectionStatusClosed;
  [[NSNotificationCenter defaultCenter] postNotificationName: J3ConnectionWasClosedByClientNotification
                                                      object: self];
}

- (void) setStatusClosedByServer
{
  status = J3ConnectionStatusClosed;
  [[NSNotificationCenter defaultCenter] postNotificationName: J3ConnectionWasClosedByServerNotification
                                                      object: self];
}

- (void) setStatusClosedWithError: (NSString *) error
{
  status = J3ConnectionStatusClosed;
  [[NSNotificationCenter defaultCenter] postNotificationName: J3ConnectionWasClosedWithErrorNotification
                                                      object: self
                                                    userInfo: [NSDictionary dictionaryWithObjectsAndKeys: error, J3ConnectionErrorMessageKey, nil]];
}

@end

#pragma mark -

@implementation J3Connection (Private)

- (void) removeNotificationFromDelegate: (NSString *) name selector: (SEL) selector andAddToObject: (id) object
{
  NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
  [notificationCenter addObserver: object selector: selector name: name object: self];
  [notificationCenter removeObserver: delegate name: name  object: self];
}

@end

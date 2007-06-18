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
  [[NSNotificationCenter defaultCenter] postNotificationName: J3ConnectionDidConnectNotification
                                                      object: self];
}

- (void) setStatusConnecting
{
  [[NSNotificationCenter defaultCenter] postNotificationName: J3ConnectionIsConnectingNotification
                                                      object: self];
}

- (void) setStatusClosedByClient
{
  [[NSNotificationCenter defaultCenter] postNotificationName: J3ConnectionWasClosedByClientNotification
                                                      object: self];
}

- (void) setStatusClosedByServer
{
  [[NSNotificationCenter defaultCenter] postNotificationName: J3ConnectionWasClosedByServerNotification
                                                      object: self];
}

- (void) setStatusClosedWithError: (NSString *) error
{
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

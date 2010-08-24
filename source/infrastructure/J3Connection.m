//
// J3Connection.m
//
// Copyright (c) 2010 3James Software.
//


#import "J3Connection.h"

@implementation J3Connection

- (void) close
{
  return;
}

- (id) init
{
  if (!(self = [super init]))
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
  return;
}

@end

#pragma mark -

@implementation J3Connection (Protected)

- (void) setStatusConnected
{
  status = J3ConnectionStatusConnected;
}

- (void) setStatusConnecting
{
  status = J3ConnectionStatusConnecting;
}

- (void) setStatusClosedByClient
{
  status = J3ConnectionStatusClosed;
}

- (void) setStatusClosedByServer
{
  status = J3ConnectionStatusClosed;
}

- (void) setStatusClosedWithError: (NSString *) error
{
  status = J3ConnectionStatusClosed;
}

@end

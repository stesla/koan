//
//  MUMockSocketConnection.m
//  Koan
//
//  Created by Samuel on 8/12/04.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import "MUMockSocketConnection.h"


@implementation MUMockSocketConnection

- (id) initWithHost:(NSString *)host port:(short)port
{
  if(self = [super initWithHost:host port:port])
  {
    _isConnected = NO;
  }
  return self;
}

- (void) close
{
  _isConnected = NO;
}

- (BOOL) isConnected
{
  return _isConnected;
}

- (BOOL) open
{
  _isConnected = YES;
  return YES;
}

- (void) mockReceiveData:(NSData *)data
{
  [self didReadData: data];
}

- (NSData *) readWrittenData
{
  return _writeBuffer;
}

- (int) writeData:(NSData *)data
{
  _writeBuffer = [data copy];
  return [_writeBuffer length];
}

@end

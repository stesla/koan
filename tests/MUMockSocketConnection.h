//
//  MUMockSocketConnection.h
//  Koan
//
//  Created by Samuel on 8/12/04.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "MUSocketConnection.h"

@interface MUMockSocketConnection : MUSocketConnection
{
  BOOL      _isConnected;
  NSData*   _writeBuffer;
}

- (id) initWithHost:(NSString *)host port:(short)port;

- (void) close;
- (BOOL) isConnected;
- (BOOL) open;
- (void) mockReceiveData:(NSData *)data;
- (NSData *) readWrittenData;
- (int) writeData:(NSData *)data;


@end

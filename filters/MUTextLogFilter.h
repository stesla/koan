//
// MUTextLogFilter.h
//
// Copyright (C) 2004 3James Software
//

#import <Cocoa/Cocoa.h>
#import "MUFilter.h"

@interface MUTextLogFilter : MUFilter
{
  NSOutputStream *output;
  NSMutableData *writeBuffer;
  NSString *errorMessage;
  // MUConnectionStatus _connectionStatus;
  // MUConnectionClosedReason _reasonClosed;
  BOOL canWrite;
  BOOL isConnected;
}

- (id) initWithOutputStream:(NSOutputStream *)stream;

@end

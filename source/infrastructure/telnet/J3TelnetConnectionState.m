//
// J3TelnetConnectionState.m
//
// Copyright (c) 2010 3James Software.
//

#import "J3TelnetConnectionState.h"

@implementation J3TelnetConnectionState

@synthesize charsetNegotiationStatus, nextTerminalTypeIndex, stringEncoding;

+ (id) connectionState
{
  return [[[self alloc] init] autorelease];
}

- (id) init
{
  if (!(self = [super init]))
    return nil;
  
  self.stringEncoding = NSASCIIStringEncoding;
  nextTerminalTypeIndex = 0;
  charsetNegotiationStatus = J3TelnetCharsetNegotiationInactive;

  return self;
}

@end

//
// J3TelnetConnectionState.h
//
// Copyright (c) 2010 3James Software.
//

#import <Cocoa/Cocoa.h>

enum charsetNegotiationStatus
{
  J3TelnetCharsetNegotiationInactive = 0,
  J3TelnetCharsetNegotiationActive = 1,
  J3TelnetCharsetNegotiationIgnoreRejected = 2
};

@interface J3TelnetConnectionState : NSObject
{
  enum charsetNegotiationStatus charsetNegotiationStatus;
  unsigned nextTerminalTypeIndex;
  NSStringEncoding stringEncoding;
}

@property (assign, nonatomic) enum charsetNegotiationStatus charsetNegotiationStatus;
@property (assign, nonatomic) unsigned nextTerminalTypeIndex;
@property (assign, nonatomic) NSStringEncoding stringEncoding;

+ (id) connectionState;

@end

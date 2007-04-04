//
// J3TelnetEngine.m
//
// Copyright (c) 2007 3James Software. All rights reserved.
//

#import "J3ReadBuffer.h"
#import "J3TelnetConstants.h"
#import "J3TelnetEngine.h"
#import "J3TelnetTextState.h"
#import "J3WriteBuffer.h"

@interface J3TelnetEngine (Private)

- (void) parseByte: (uint8_t) byte;
- (void) sendCommand: (uint8_t) command withByte: (uint8_t) byte;

@end

@implementation J3TelnetEngine

+ (id) engine
{
  return [[[self alloc] init] autorelease];
}

- (id) init
{
  if (![super init])
    return nil;
  [self at: &state put: [J3TelnetTextState state]];
  return self;
}

- (void) bufferInputByte: (uint8_t) byte
{
  [delegate bufferInputByte: byte];
}

- (void) bufferOutputByte: (uint8_t) byte
{
  [delegate bufferOutputByte: byte];
}

- (void) dealloc
{
  [state release];
  [super dealloc];
}

- (void) dont: (uint8_t) byte;
{
  NSLog (@"    Sent: IAC DONT %@", [self optionNameForByte: byte]);
  [self sendCommand: J3TelnetDont withByte: byte];
}

- (void) goAhead;
{
  [self bufferOutputByte: J3TelnetInterpretAsCommand];
  [self bufferOutputByte: J3TelnetGoAhead];
  [delegate flushOutput];
}

- (NSString *) optionNameForByte: (uint8_t) byte
{
  switch (byte)
  {
    case J3TelnetEcho:
      return @"ECHO";
    
  	case J3TelnetSuppressGoAhead:
  		return @"SUPPRESS-GO-AHEAD";
  		
  	case J3TelnetTerminalType:
  		return @"TERMINAL-TYPE";
  		
  	case J3TelnetEndOfRecord:
  		return @"END-OF-RECORD";
  		
  	case J3TelnetNegotiateAboutWindowSize:
  		return @"NAWS";
  		
  	case J3TelnetLineMode:
  		return @"LINEMODE";
  		
  	case J3TelnetMCCP1:
  		return @"COMPRESS (MCCP1)";
  		
  	case J3TelnetMCCP2:
  		return @"COMPRESS2 (MCCP2)";
  		
    case J3TelnetMSP:
      return @"MSP";
      
    case J3TelnetMXP:
      return @"MXP";
      
  	default:
  		return [NSString stringWithFormat: @"%u (unknown option)", (unsigned) byte];
  }
}

- (void) parseData: (NSData *) data
{
  for (unsigned i = 0; i < [data length]; i++)
    [self parseByte: ((uint8_t *) [data bytes])[i]];
}

- (void) setDelegate: (NSObject <J3TelnetEngineDelegate> *) object
{
  delegate = object;
}

- (void) wont: (uint8_t) byte;
{
  NSLog (@"    Sent: IAC WONT %@", [self optionNameForByte: byte]);
  [self sendCommand: J3TelnetWont withByte: byte];
}

@end

@implementation J3TelnetEngine (Private)

- (void) parseByte: (uint8_t) byte
{
  [self at: &state put: [state parse: byte forParser: self]];
}

- (void) sendCommand: (uint8_t) command withByte: (uint8_t) byte;
{
  [self bufferOutputByte: J3TelnetInterpretAsCommand];
  [self bufferOutputByte: command];
  [self bufferOutputByte: byte];
  [delegate flushOutput];
}

@end


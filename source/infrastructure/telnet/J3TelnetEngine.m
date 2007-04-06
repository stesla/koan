//
// J3TelnetEngine.m
//
// Copyright (c) 2007 3James Software.
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

#pragma mark -

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

- (void) dealloc
{
  [state release];
  [super dealloc];
}

- (void) dont: (uint8_t) byte
{
  [self log: @"    Sent: IAC DONT %@", [self optionNameForByte: byte]];
  [self sendCommand: J3TelnetDont withByte: byte];
}

- (void) goAhead
{
  uint8_t bytes[] = {J3TelnetInterpretAsCommand, J3TelnetGoAhead};
  [delegate writeData: [NSData dataWithBytes: bytes length: 2]];
}

- (void) log: (NSString *) message, ...
{
  va_list args;
  va_start (args, message);
  
  [delegate log: message arguments: args];
  
  va_end (args);
}

- (NSString *) optionNameForByte: (uint8_t) byte
{
  switch (byte)
  {
    case J3TelnetOptionEcho:
      return @"ECHO";
      
    case J3TelnetOptionStatus:
      return @"STATUS";
    
  	case J3TelnetOptionSuppressGoAhead:
  		return @"SUPPRESS-GO-AHEAD";
  		
  	case J3TelnetOptionTerminalType:
  		return @"TERMINAL-TYPE";
  		
  	case J3TelnetOptionEndOfRecord:
  		return @"END-OF-RECORD";
  		
  	case J3TelnetOptionNegotiateAboutWindowSize:
  		return @"NAWS";
      
    case J3TelnetOptionTerminalSpeed:
      return @"TERMINAL-SPEED";
      
    case J3TelnetOptionToggleFlowControl:
      return @"TOGGLE-FLOW-CONTROL";
  		
  	case J3TelnetOptionLineMode:
  		return @"LINEMODE";
      
    case J3TelnetOptionXDisplayLocation:
      return @"X-DISPLAY-LOCATION";
      
    case J3TelnetOptionNewEnviron:
      return @"NEW-ENVIRON";
  		
  	case J3TelnetOptionMCCP1:
  		return @"COMPRESS (MCCP1)";
  		
  	case J3TelnetOptionMCCP2:
  		return @"COMPRESS2 (MCCP2)";
  		
    case J3TelnetOptionMSP:
      return @"MSP";
      
    case J3TelnetOptionMXP:
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

- (NSData *) preprocessOutput: (NSData *) data
{
  const uint8_t *bytes = [data bytes];
  NSMutableData *result = [NSMutableData dataWithCapacity: [data length]];
  for (unsigned i = 0; i < [data length]; ++i)
  {
    if (bytes[i] == J3TelnetInterpretAsCommand)
      [result appendBytes:  bytes + i length: 1];
    [result appendBytes: bytes + i length: 1];
  }
  return result;
}

- (void) setDelegate: (NSObject <J3TelnetEngineDelegate> *) object
{
  delegate = object;
}

- (void) wont: (uint8_t) byte
{
  [self log: @"    Sent: IAC WONT %@", [self optionNameForByte: byte]];
  [self sendCommand: J3TelnetWont withByte: byte];
}

@end

#pragma mark -

@implementation J3TelnetEngine (Private)

- (void) parseByte: (uint8_t) byte
{
  [self at: &state put: [state parse: byte forParser: self]];
}

- (void) sendCommand: (uint8_t) command withByte: (uint8_t) byte
{
  uint8_t bytes[] = {J3TelnetInterpretAsCommand, command, byte};
  [delegate writeData: [NSData dataWithBytes: bytes length: 3]];
}

@end


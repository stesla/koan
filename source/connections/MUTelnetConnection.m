//
// MUTelnetConnection.m
//
// Copyright (C) 2004 Tyler Berry and Samuel Tesla
//
// Koan is free software; you can redistribute it and/or modify it under the
// terms of the GNU General Public License as published by the Free Software
// Foundation; either version 2 of the License, or (at your option) any later
// version.
//
// Koan is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// Koan; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
// Suite 330, Boston, MA 02111-1307 USA
//

#import "MUTelnetConnection.h"

#include <string.h>

@interface MUTelnetConnection (Private)
- (BOOL) parseCommandMaybe:(uint8_t)current;
- (void) readFromStream:(NSInputStream *)stream;
- (void) writeToStream:(NSOutputStream *)stream;
@end

@interface MUTelnetConnection (TelnetCommands)
- (BOOL) doInterpretAsCommand;
- (BOOL) doNoOperation;
- (BOOL) doDoOrDont;
- (BOOL) doWillOrWont;
@end

@implementation MUTelnetConnection

- (id) init
{
  if (self = [super init])
  {
    _readBuffer = [[NSMutableData alloc] init];
    _writeBuffer = [[NSMutableData alloc] init];
    _isInCommand = NO;
    _discardNextByte = NO;
  }
  return self;
}

- (void) dealloc
{
  [_readBuffer release];
  [_writeBuffer release];
  [super dealloc];
}

- (NSString *) read
{
  NSString *result;
  if ([_readBuffer length])
  {
    result = [[NSString alloc] initWithData:_readBuffer
                                   encoding:NSASCIIStringEncoding];
    [result autorelease];
    [_readBuffer setData:[NSData data]];
  }
  else
  {
    result = @"";
  }
  return result;
}

- (void) writeData:(NSData *)data
{
  [_writeBuffer appendData:data];
}

- (void) writeString:(NSString *)string
{
  NSData *data = [string dataUsingEncoding:NSASCIIStringEncoding];
  [self writeData:data];
}

- (BOOL) isInCommand
{
  return _isInCommand;
}

// NSStream delegate
- (void) stream:(NSStream *)stream handleEvent:(NSStreamEvent)event
{
  switch(event)
  {
    case NSStreamEventHasBytesAvailable: 
    {      
      [self readFromStream:(NSInputStream *)stream];
      break;
    }
    case NSStreamEventEndEncountered:
    case NSStreamEventErrorOccurred:
    case NSStreamEventHasSpaceAvailable:
    {
      [self writeToStream:(NSOutputStream *)stream];
      break;
    }
    case NSStreamEventOpenCompleted:
    case NSStreamEventNone:
    default:
      return;
  }
}
@end

@implementation MUTelnetConnection (Private)
// Returns true if this was a command character
- (BOOL) parseCommandMaybe:(uint8_t)current
{
  if (current >= TEL_SE) // I don't need the high end, because 255 is the highest value it could be
  {
    switch (current)
    {
      case TEL_IAC:
        return [self doInterpretAsCommand];
        
      case TEL_NOP:
        return [self doNoOperation];
      
      case TEL_WILL:
      case TEL_WONT:
        return [self doWillOrWont];
        
      case TEL_DO:
      case TEL_DONT:
        return [self doDoOrDont];
        
      default:
        return true;
    }
  }
  return false;
}

- (void) readFromStream:(NSInputStream *)stream
{
  int i;
  uint8_t socketBuffer[MUTelnetBufferMax];
  bzero(socketBuffer, MUTelnetBufferMax);
  unsigned int bytesRead = [stream read:socketBuffer maxLength:MUTelnetBufferMax];
  uint8_t dataBuffer[bytesRead];
  bzero(dataBuffer, bytesRead);
  int bytesWritten = 0;
  for (i = 0; i < bytesRead; i++)
  {
    if (_discardNextByte)
      _discardNextByte = NO;
    else
    {
      if (![self parseCommandMaybe:socketBuffer[i]])
      {
        dataBuffer[bytesWritten] = socketBuffer[i];
        bytesWritten++;
      }
    }
  }
  
  if (bytesRead)
  {
    [_readBuffer appendBytes:(const void *)dataBuffer length:bytesWritten];
  }
}

- (void) writeToStream:(NSOutputStream *)stream
{
  const uint8_t *buffer = [_writeBuffer bytes];
  [stream write:buffer maxLength:[_writeBuffer length]];
  [_writeBuffer setData:[NSData data]];
}

@end

@implementation MUTelnetConnection (TelnetCommands)
- (BOOL) doInterpretAsCommand
{
  if ([self isInCommand])
    return false;
  else
  {
    _isInCommand = true;
    return true;
  }
  
}

- (BOOL) doNoOperation
{
  if ([self isInCommand])
    return true;
  else
    return false;
}

- (BOOL) doWillOrWont
{
  if ([self isInCommand])
  {
    char command[2];
    command[0] = TEL_IAC;
    command[1] = TEL_WONT;
    NSData *data = [NSData dataWithBytes:(const void *)command length:2];
    [self writeData:data];
    _discardNextByte = YES;
  }
  return true;
}

- (BOOL) doDoOrDont
{
  if ([self isInCommand])
  {
    char command[2];
    command[0] = TEL_IAC;
    command[1] = TEL_DONT;
    NSData *data = [NSData dataWithBytes:(const void *)command length:2];
    [self writeData:data];
    _discardNextByte = YES;    
  }
  return true;
}

@end

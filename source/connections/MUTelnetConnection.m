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
@end

@implementation MUTelnetConnection

- (id) init
{
  if (self = [super init])
  {
    _data = [[NSMutableData alloc] init];
    _outputBuffer = [[NSMutableData alloc] init];
    _isInCommand = NO;
  }
  return self;
}

- (void) dealloc
{
  [_data release];
  [_outputBuffer release];
  [super dealloc];
}

- (NSString *) read
{
  NSString *result;
  if ([_data length])
  {
    result = [[NSString alloc] initWithData:_data
                                   encoding:NSASCIIStringEncoding];
    [result autorelease];
    [_data setData:[NSData data]];
  }
  else
  {
    result = @"";
  }
  return result;
}

- (void) write:(NSString *)string
{
  NSData *data = [string dataUsingEncoding:NSASCIIStringEncoding];
  [_outputBuffer appendData:data];
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
    if (![self parseCommandMaybe:socketBuffer[i]])
    {
      dataBuffer[bytesWritten] = socketBuffer[i];
      bytesWritten++;
    }
  }
  
  if (bytesRead)
  {
    [_data appendBytes:(const void *)dataBuffer length:bytesWritten];
  }
}

- (void) writeToStream:(NSOutputStream *)stream
{
  const uint8_t *buffer = [_outputBuffer bytes];
  [stream write:buffer maxLength:[_outputBuffer length]];
  [_outputBuffer setData:[NSData data]];
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

@end

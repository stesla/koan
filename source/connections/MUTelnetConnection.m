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

@implementation MUTelnetConnection

- (id) init
{
  if (self = [super init])
  {
    _data = [[NSMutableData alloc] init];
    _isInCommand = NO;
  }
  return self;
}

- (void) dealloc
{
  [_data release];
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
      int i;
      uint8_t buffer[MUTelnetBufferMax];
      bzero(buffer, MUTelnetBufferMax);
      unsigned int bytesRead = [(NSInputStream *)stream read:buffer maxLength:MUTelnetBufferMax];
      for (i = 0; i < bytesRead; i++)
      {
        if (buffer[i] == TEL_IAC)
        {
          _isInCommand = true;
        }
      }
      
      if (bytesRead)
      {
        [_data appendBytes:(const void *)buffer length:bytesRead];
      }
      
      break;
    }
    case NSStreamEventEndEncountered:
    case NSStreamEventErrorOccurred:
    case NSStreamEventHasSpaceAvailable:
    case NSStreamEventOpenCompleted:
    case NSStreamEventNone:
    default:
      return;
  }
}

@end
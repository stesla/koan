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
- (void) readFromStream:(NSInputStream *)stream;
// WARNING - Counter must be a valid offset from buffer.
// The value of counter may change inside this routine.
- (void) processByte:(uint8_t)byte withBuffer:(uint8_t *)buffer at:(int *)counter;
- (void) appendBytesToBuffer:(const void *)bytes length:(int)length;
- (void) writeToStream:(NSOutputStream *)stream;
- (void) closeWithMessage:(NSString *)message;
@end

@interface MUTelnetConnection (DelegateMethods)
- (void) connectionDidEnd;
- (void) didReadLine;
- (void) statusMessage:(NSString *)message;
@end

@interface MUTelnetConnection (TelnetCommands)
- (void) doDo:(uint8_t)option;
- (void) doDont:(uint8_t)option;
- (void) doWill:(uint8_t)option;
- (void) doWont:(uint8_t)option;
- (void) sendWont;
- (void) sendDont;
@end

@implementation MUTelnetConnection

- (id) init
{
  return nil;
}

- (id) initWithInputStream:(NSInputStream *)input  
              outputStream:(NSOutputStream *)output
{
  if (self = [super init])
  {
    [self setInput:input];
    [self setOutput:output];
    _readBuffer = [[NSMutableData alloc] init];
    _writeBuffer = [[NSMutableData alloc] init];
    _isConnected = NO;
    _isInCommand = NO;
    _commandChar = TEL_NONE;
  }
  return self;
}

- (id) initWithHostName:(NSString *)hostName
                 onPort:(int)port;
{
  NSInputStream *input;
  NSOutputStream *output;
  NSHost *host = [NSHost hostWithName:hostName];
  [NSStream getStreamsToHost:host
                        port:port
                 inputStream:&input
                outputStream:&output];
  
  return [self initWithInputStream:input
                      outputStream:output];
}

- (void) dealloc
{
  if ([self isConnected])
    [self close];
  [_input release];
  [_output release];
  [_readBuffer release];
  [_writeBuffer release];
  [super dealloc];
}

- (id) delegate
{
  return _delegate;
}

- (void) setDelegate:(id)delegate
{
  if (delegate && ![delegate respondsToSelector:@selector(telnetDidReadLine:)])
    NSLog (@"Warning: setting delegate to object '%@'," 
           "which does not respond to delegate method "
           "telnetDidReadLine:.", delegate);
  
  if (delegate && ![delegate respondsToSelector:@selector(telnetConnectionDidEnd:)])
    NSLog (@"Warning: setting delegate to object '%@',"
           "which does not respond to delegate method "
           "telnetConnectionDidEnd:.", delegate);
  
  _delegate = delegate;
}

- (NSInputStream *) input
{
  return _input;
}

- (void) setInput:(NSInputStream *)input
{
  [input retain];
  [_input release];
  _input = input;
  [_input setDelegate:self];
  [_input scheduleInRunLoop:[NSRunLoop currentRunLoop]
                    forMode:NSDefaultRunLoopMode];
}

- (NSOutputStream *) output
{
  return _output;
}

- (void) setOutput:(NSOutputStream *)output
{
  [output retain];
  [_output release];
  _output = output;
  [_output setDelegate:self];
  [_output scheduleInRunLoop:[NSRunLoop currentRunLoop]
                     forMode:NSDefaultRunLoopMode];
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
  if (_canWrite)
    [self writeToStream:_output];
}

- (void) writeString:(NSString *)string
{
  NSData *data = [string dataUsingEncoding:NSASCIIStringEncoding];
  [self writeData:data];
}

- (void) open
{
  if (![self isConnected])
  {
    [self statusMessage:@"Trying to open connection..."];
    [_input open];
    [_output open];
    _isConnected = YES;
  }
}

- (void) close
{
  [self closeWithMessage:@"Connection closed."];
}

- (BOOL) isConnected
{
  return _isConnected;
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
      [self readFromStream:(NSInputStream *)stream];
      break;
      
    case NSStreamEventHasSpaceAvailable:
      if ([_writeBuffer length] > 0)
      {
        [self writeToStream:(NSOutputStream *)stream];
        _canWrite = NO;
      }
      else
        _canWrite = YES;
      break;
      
    case NSStreamEventOpenCompleted:
      // Without checking to see if the stream which has successfully opened is
      // the input stream, two 'Connected' messages are signalled to the
      // delegate. I chose the input stream because it is guaranteed to open
      // before any data is read, so the connection will be noted before any
      // reads occur, placing all the various messages in the right order.
      //
      // Checking if both streams were successfully opened still printed both
      // 'Connected' messages; apparently they both finish quickly enough that
      // they beat out the event. - T
      if (stream == _input)
        [self statusMessage:@"Connected."];
      break;
      
    case NSStreamEventEndEncountered:
      [self closeWithMessage:@"Connection closed by server."];
      [self connectionDidEnd];
      break;

    case NSStreamEventErrorOccurred:
      [self closeWithMessage:
        [NSString stringWithFormat:@"Connection closed on error: %@", 
          [[stream streamError] localizedDescription]]];
      [self connectionDidEnd];
      break;
      
    case NSStreamEventNone:
    default:
      return;
  }
}

@end

@implementation MUTelnetConnection (Private)

- (void) readFromStream:(NSInputStream *)stream
{
  int i;
  uint8_t socketBuffer[MUTelnetBufferMax];
  memset(socketBuffer, 0, MUTelnetBufferMax);
  unsigned int bytesRead = [stream read:socketBuffer 
                              maxLength:MUTelnetBufferMax];
  
  uint8_t dataBuffer[bytesRead];
  memset(dataBuffer, 0, bytesRead);
  int bytesWritten = 0;
  for (i = 0; i < bytesRead; i++)
  {
    [self processByte:socketBuffer[i] 
           withBuffer:dataBuffer
                   at:&bytesWritten];
  }
  
  [self appendBytesToBuffer:(const void *)dataBuffer length:bytesWritten];
}

- (void) processByte:(uint8_t)byte withBuffer:(uint8_t *)buffer at:(int *)counter
{
  if ([self isInCommand])
  {
    if (_commandChar == TEL_NONE)
    {
      _commandChar = byte;
      switch (_commandChar)
      {
        case TEL_IAC:
          buffer[*counter] = _commandChar;
          (*counter)++;
          _isInCommand = false;
          break;
          
        case TEL_NOP:
          _isInCommand = false;
          break;
      }
    }
    else
    {
      switch(_commandChar)
      {
        case TEL_DO:
          [self doDo:byte];
          break;
        
        case TEL_DONT:
          [self doDont:byte];
          break;
          
        case TEL_WILL:
          [self doWill:byte];
          break;
          
        case TEL_WONT:
          [self doWont:byte];
          break;
      }
      
      _isInCommand = false;      
    }
  }
  else
  {
    if (byte == TEL_IAC)
    {
      _isInCommand = true;
      _commandChar = TEL_NONE;
    }
    else
    {
      buffer[*counter] = byte;
      (*counter)++;
      if (byte == '\n')
      {
        [self appendBytesToBuffer:(const void *)buffer length:*counter];
        [self didReadLine];
        [_readBuffer setData:[NSData data]];
        memset(buffer, 0, *counter);
        *counter = 0;
      }
    }
  }
}

- (void) appendBytesToBuffer:(const void *)bytes length:(int)length
{
  if (length)
  {
    [_readBuffer appendBytes:bytes length:length];
  }
}

- (void) writeToStream:(NSOutputStream *)stream
{
  const uint8_t *buffer = [_writeBuffer bytes];
  [stream write:buffer maxLength:[_writeBuffer length]];
  [_writeBuffer setData:[NSData data]];
}

- (void) closeWithMessage:(NSString *)message
{
  if ([self isConnected])
  {
    [_input close];
    [_output close];
    _isConnected = NO;
    [self statusMessage:message];
  }  
}

@end

@implementation MUTelnetConnection (TelnetCommands)

- (void) doDo:(uint8_t)option
{
  // We won't do anything
  [self sendWont];
}

- (void) doDont:(uint8_t)option
{
  // We wont do anything
  [self sendWont];
}

- (void) doWill:(uint8_t)option
{
  // We dont do anything
  [self sendDont];
}

- (void) doWont:(uint8_t)option
{
  // We dont do anything
  [self sendDont];
}

- (void) sendDont
{
  char command[2];
  command[0] = TEL_IAC;
  command[1] = TEL_DONT;
  NSData *data = [NSData dataWithBytes:(const void *)command length:2];
  [self writeData:data];
}

- (void) sendWont
{
  char command[2];
  command[0] = TEL_IAC;
  command[1] = TEL_WONT;
  NSData *data = [NSData dataWithBytes:(const void *)command length:2];
  [self writeData:data];
}

@end

@implementation MUTelnetConnection (DelegateMethods)

- (void) connectionDidEnd
{
  if ([_delegate respondsToSelector:@selector(telnetConnectionDidEnd:)])
    [_delegate telnetConnectionDidEnd:self];  
}

- (void) didReadLine
{
  if ([_delegate respondsToSelector:@selector(telnetDidReadLine:)])
    [_delegate telnetDidReadLine:self];
}

- (void) statusMessage:(NSString *)message
{
  if ([_delegate respondsToSelector:@selector(telnet:statusMessage:)])
    [_delegate telnet:self statusMessage:message];
}

@end
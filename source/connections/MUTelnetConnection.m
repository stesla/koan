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

NSString *MUConnectionConnecting = @"MUConnectionConnecting";
NSString *MUConnectionConnected = @"MUConnectionConnected";
NSString *MUConnectionClosed = @"MUConnectionClosed";

@interface MUTelnetConnection (Private)
- (void) readFromStream:(NSInputStream *)stream;
- (void) appendByteToBuffer:(uint8_t)byte;
- (void) processByte:(uint8_t)byte;
- (void) processCommandChar:(uint8_t)byte;
- (void) processOptionChar:(uint8_t)byte;
- (void) appendBytesToBuffer:(const void *)bytes length:(int)length;
- (void) writeToStream:(NSOutputStream *)stream;
- (void) setErrorMessage:(NSString *)message;
- (void) closeWithReason:(MUConnectionClosedReason)reason;
@end

@interface MUTelnetConnection (StatusChangeMethods)
- (void) connectionClosed;
- (void) connectionConnecting;
- (void) connectionConnected;
@end

@interface MUTelnetConnection (DelegateMethods)
- (void) didReadLine;
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
    _errorMessage = @"";
    _isConnected = NO;
    _isInCommand = NO;
    _connectionStatus = MUConnectionStatusNotConnected;
    _reasonClosed = MUConnectionClosedReasonNotClosed;
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
  [_errorMessage release];
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
  
  _delegate = delegate;
}

- (NSString *) errorMessage
{
  return _errorMessage;
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
    [self connectionConnecting];
    [_input open];
    [_output open];
    _isConnected = YES;
  }
}

- (void) close
{
  [self closeWithReason:MUConnectionClosedReasonClient];
}

- (BOOL) isConnected
{
  return _isConnected;
}

- (BOOL) isError
{
  return [_errorMessage length];
}

- (BOOL) isInCommand
{
  return _isInCommand;
}

- (MUConnectionStatus) connectionStatus
{
  return _connectionStatus;
}

- (MUConnectionClosedReason) reasonClosed
{
  return _reasonClosed;
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
        [self connectionConnected];
      break;
      
    case NSStreamEventEndEncountered:
      [self closeWithReason:MUConnectionClosedReasonServer];
      break;

    case NSStreamEventErrorOccurred:
      [self setErrorMessage:
        [[stream streamError] localizedDescription]];
      [self closeWithReason:MUConnectionClosedReasonError];
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
  
  for (i = 0; i < bytesRead; i++)
  {
    if ([self isInCommand])
    {
      if (_commandChar == TEL_NONE)
        [self processCommandChar:socketBuffer[i]];
      else
        // The only time that we will still be in the command state
        // and also have a _commandChar other than TEL_NONE is during
        // option negotiation (WILL, WONT, DO, DONT) - ST
        [self processOptionChar:socketBuffer[i]];
    }
    else
    {
      if (socketBuffer[i] == TEL_IAC)
      {
        _isInCommand = true;
        _commandChar = TEL_NONE;
      }
      else
      {
        [self processByte:socketBuffer[i]];
      }
    }
  }
}

- (void) processCommandChar:(uint8_t)byte
{
  _commandChar = byte;
  switch (_commandChar)
  {
    case TEL_IAC:
      [self appendByteToBuffer:TEL_IAC];
      _isInCommand = false;
      break;
      
    case TEL_NOP:
      _isInCommand = false;
      break;
  }
}

- (void) processOptionChar:(uint8_t)byte
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

- (void) processByte:(uint8_t)byte
{
  [self appendByteToBuffer:byte];
  if (byte == '\n')
  {
    [self didReadLine];
    [_readBuffer setData:[NSData data]];
  }
}

- (void) appendByteToBuffer:(uint8_t)byte
{
  uint8_t bytes[1];
  bytes[0] = byte;
  [self appendBytesToBuffer:bytes length:1];
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

- (void) setErrorMessage:(NSString *)message
{
  [message retain];
  [_errorMessage release];
  _errorMessage = message;
}

- (void) closeWithReason:(MUConnectionClosedReason)reason
{
  if ([self isConnected])
  {
    [_input close];
    [_output close];
    _isConnected = NO;
    _reasonClosed = reason;
    [self connectionClosed];
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

@implementation MUTelnetConnection (StatusChangeMethods)

- (void) connectionClosed
{
  _connectionStatus = MUConnectionStatusClosed;
  
  NSNotificationCenter *notificationCenter;
  notificationCenter = [NSNotificationCenter defaultCenter];
  [notificationCenter postNotificationName:MUConnectionClosed
                                    object:self];
}

- (void) connectionConnecting
{
  _connectionStatus = MUConnectionStatusConnecting;
  
  NSNotificationCenter *notificationCenter;
  notificationCenter = [NSNotificationCenter defaultCenter];
  [notificationCenter postNotificationName:MUConnectionConnecting
                                    object:self];  
}

- (void) connectionConnected
{
  _connectionStatus = MUConnectionStatusConnected;
  
  NSNotificationCenter *notificationCenter;
  notificationCenter = [NSNotificationCenter defaultCenter];
  [notificationCenter postNotificationName:MUConnectionConnected
                                    object:self];  
}

@end

@implementation MUTelnetConnection (DelegateMethods)

- (void) didReadLine
{
  if ([_delegate respondsToSelector:@selector(telnetDidReadLine:)])
    [_delegate telnetDidReadLine:self];
}

@end
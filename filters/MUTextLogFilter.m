//
// MUTextLogFilter.m
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

#import "MUTextLogFilter.h"

@interface MUTextLogFilter (Private)
- (void) log:(NSAttributedString *)editString;
@end

@implementation MUTextLogFilter

+ (MUFilter *) filter
{
  return [[[MUTextLogFilter alloc] init] autorelease];
}

- (id) init
{
  return [self initWithOutputStream:[NSOutputStream outputStreamToFileAtPath:[@"~/Koan.log" stringByExpandingTildeInPath]
                                                                      append:YES]];
}

- (id) initWithOutputStream:(NSOutputStream *)stream
{
  if (self = [super init])
  {
    _output = [stream retain];
    [_output open];
    _writeBuffer = [[NSMutableData alloc] init];
    _errorMessage = @"";
    _isConnected = NO;
    // _connectionStatus = MUConnectionStatusNotConnected;
    // _reasonClosed = MUConnectionClosedReasonNotClosed;
  }
  return self;
}

- (void) dealloc
{
  [_output close];
  [_output release];
}

- (NSAttributedString *) filter:(NSAttributedString *)string
{
  [self log:string];
  
  return string;
}

@end

@implementation MUTextLogFilter (Private)

- (void) log:(NSAttributedString *)string
{
  const char *buffer = [[string string] UTF8String];
  
  [_output write:(uint8_t *) buffer maxLength:strlen (buffer)];
}

@end
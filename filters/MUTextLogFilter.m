//
// MUTextLogFilter.m
//
// Copyright (C) 2004 3James Software
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
    output = [stream retain];
    [output open];
    writeBuffer = [[NSMutableData alloc] init];
    errorMessage = @"";
    isConnected = NO;
    // connectionStatus = MUConnectionStatusNotConnected;
    // reasonClosed = MUConnectionClosedReasonNotClosed;
  }
  return self;
}

- (void) dealloc
{
  [output close];
  [output release];
}

- (NSAttributedString *) filter:(NSAttributedString *)string
{
  if ([string length] > 0)
    [self log:string];
  
  return string;
}

@end

@implementation MUTextLogFilter (Private)

- (void) log:(NSAttributedString *)string
{
  const char *buffer = [[string string] UTF8String];
  
  [output write:(uint8_t *) buffer maxLength:strlen (buffer)];
}

@end

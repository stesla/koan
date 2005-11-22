//
// J3Buffer.m
//
// Copyright (c) 2005 3James Software
//

#import "J3Buffer.h"

@implementation J3Buffer

+ (id) buffer
{
  return [[[self alloc] init] autorelease];
}

- (id) init
{
  if (![super init])
    return nil;
  [self clear];
  return self;
}

- (void) setDataValue:(NSData *)newDataValue
{
  NSMutableData *copy = [[NSMutableData alloc] initWithData:newDataValue];
  [data release];
  data = copy;
}

#pragma mark -
#pragma mark J3Buffer protocol

- (void) append:(uint8_t)byte
{
  char bytes[1] = {byte};
  [data appendBytes:bytes length:1];
}

- (void) appendLine:(NSString *)line
{
  [self appendString:line];
  [self append:'\n'];
}

- (void) appendString:(NSString *)string
{
  const char *bytes = [string cStringUsingEncoding:NSASCIIStringEncoding];
  unsigned length = strlen (bytes);
  unsigned i;
  
  for (i = 0; i < length; i++)
    [self append:bytes[i]];
}

- (const void *)bytes
{
  return [data bytes];
}

- (void) clear
{
  [self setDataValue:[NSData data]];
}

- (NSData *) dataValue
{
  return [NSData dataWithData:data];
}

- (void) flush;
{
}

- (BOOL) isEmpty
{
  return [self length] == 0;
}

- (unsigned) length
{
  return [data length];
}

- (NSString *) stringValue
{
  return [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
}

@end

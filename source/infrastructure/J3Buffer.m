//
// J3Buffer.m
//
// Copyright (c) 2005, 2006 3James Software
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

- (void) removeDataNotInRange:(NSRange)range
{
  [self setDataValue:[[self dataValue] subdataWithRange:range]];  
}

- (void) removeDataUpTo:(unsigned)position
{
  NSRange range;
  range.location = position;
  range.length = [self length] - position;
  [self removeDataNotInRange:range];
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
  [self appendBytes:bytes length:1];
}

- (void) appendBytes:(const void *)bytes length:(unsigned)length;
{
  [data appendBytes:bytes length:length];
}

- (void) appendLine:(NSString *)line
{
  [self appendString:line];
  [self append:'\n'];
}

- (void) appendString:(NSString *)string
{
  NSData *stringData;
  unsigned i;
  
  if (!string)
    return;
  
  stringData = [string dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
  
  for (i = 0; i < [stringData length]; i++)
    [self append:((const char *)[stringData bytes])[i]];
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

- (void) flush
{
  // Base implementation does nothing.
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

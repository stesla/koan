//
//  J3Buffer.m
//  NewTelnet
//
//  Created by Samuel Tesla on 11/10/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "J3Buffer.h"

@implementation J3Buffer
+ (id) buffer;
{
  return [[[self alloc] init] autorelease];
}

- (void) append:(uint8_t)byte;
{
  char bytes[1] = {byte};
  [buffer appendBytes:bytes length:1];
}

- (void) appendLine:(NSString *)line;
{
  [self appendString:line];
  [self append:'\n'];
}

- (void) appendString:(NSString *)string;
{
  const char * bytes = [string cStringUsingEncoding:NSASCIIStringEncoding];
  unsigned int length = strlen(bytes);
  unsigned int i;
  for (i = 0; i < length; i++)
    [self append:bytes[i]];
}

- (void) clear;
{
  [self setBuffer:[NSData data]];
}

- (NSData *) dataValue;
{
  return [NSData dataWithData:buffer];
}

- (id) init;
{
  if (![super init])
    return nil;
  [self clear];
  return self;
}

- (BOOL) isEmpty;
{
  return [self length] == 0;
}

- (unsigned int) length;
{
  return [buffer length];
}

- (void) setBuffer:(NSData *)newBuffer;
{
  NSMutableData * copy = [[NSMutableData alloc] initWithData:newBuffer];
  [buffer release];
  buffer = copy;
}

- (NSString *) stringValue;
{
  return [[[NSString alloc] initWithData:buffer encoding:NSASCIIStringEncoding] autorelease];
}

@end
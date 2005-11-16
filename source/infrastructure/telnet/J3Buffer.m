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

- (void) clear;
{
  buffer = [NSMutableData data];
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

- (NSString *) stringValue;
{
  return [[[NSString alloc] initWithData:buffer encoding:NSASCIIStringEncoding] autorelease];
}

@end
//
//  MUTelnetConnectionTests.m
//  Koan
//
//  Created by Samuel on 9/16/04.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import "MUTelnetConnectionTests.h"
#import "MUTelnetConnection.h"

@implementation MUTelnetConnectionTests

- (NSInputStream *) prepareInputStreamWithBytes:(const char *)bytes length:(int)length
{
  NSData *data = [NSData dataWithBytes:bytes length:length];
  return [NSInputStream inputStreamWithData:data];
}

- (void) testReadThreeBytes
{
  const char *data = [[@"foo" dataUsingEncoding:NSASCIIStringEncoding] bytes];
  NSInputStream *stream = [self prepareInputStreamWithBytes:data length:4];
  [stream open];  
  MUTelnetConnection *telnet = [[MUTelnetConnection alloc] init];
  [telnet stream:stream handleEvent:NSStreamEventHasBytesAvailable];
  NSString *result = [telnet read];
  [self assert:result equals:@"foo"];
  [telnet release];
}

- (void) testReadTwice
{
  const char *data = [[@"foo" dataUsingEncoding:NSASCIIStringEncoding] bytes];
  NSInputStream *stream = [self prepareInputStreamWithBytes:data length:4];
  [stream open];
  MUTelnetConnection *telnet = [[MUTelnetConnection alloc] init];
  [telnet stream:stream handleEvent:NSStreamEventHasBytesAvailable];

  data = [[@"bar" dataUsingEncoding:NSASCIIStringEncoding] bytes];
  stream = [self prepareInputStreamWithBytes:data length:4];
  [stream open];
  [telnet stream:stream handleEvent:NSStreamEventHasBytesAvailable];
  
  NSString *result = [telnet read];
  [self assert:result equals:@"foobar"];
  [telnet release];
}

@end

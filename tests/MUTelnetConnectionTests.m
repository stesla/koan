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

- (void) setUp
{
  _telnet = [[MUTelnetConnection alloc] init];
}

- (void) tearDown
{
  [_telnet release];
}

- (void) testRead
{
  NSData *data = [NSData dataWithBytes:(const void *)"Foo" length:3];
  NSInputStream *input = [NSInputStream inputStreamWithData:data];
  [input open];
  [_telnet stream:input handleEvent:NSStreamEventHasBytesAvailable];
  NSString *telnetString = [_telnet read];
  [self assert:telnetString equals:@"Foo"];
}

- (void) testConsecutiveReads
{
  NSData *data = [NSData dataWithBytes:(const void *)"Foo" length:3];
  NSInputStream *input = [NSInputStream inputStreamWithData:data];
  [input open];
  
  [_telnet stream:input handleEvent:NSStreamEventHasBytesAvailable];
  data = [NSData dataWithBytes:(const void *)"Bar" length:3];
  input = [NSInputStream inputStreamWithData:data];
  [input open];
  [_telnet stream:input handleEvent:NSStreamEventHasBytesAvailable];
  NSString *telnetString = [_telnet read];
  [self assert:telnetString equals:@"FooBar"];
  telnetString = [_telnet read];
  [self assert:telnetString equals:@""];
  
  [_telnet stream:input handleEvent:NSStreamEventHasBytesAvailable];
  data = [NSData dataWithBytes:(const void *)"Baz" length:3];
  input = [NSInputStream inputStreamWithData:data];
  [input open];
  [_telnet stream:input handleEvent:NSStreamEventHasBytesAvailable];
  telnetString = [_telnet read];  
  [self assert:telnetString equals:@"Baz"];
}

- (void) testIsInCommand
{
  char cstring[2];
  cstring[0] = 'a';
  cstring[1] = TEL_IAC;
  NSData *data = [NSData dataWithBytes:(const void *)cstring length:2];
  NSInputStream *input = [NSInputStream inputStreamWithData:data];
  [input open];
  
  [_telnet stream:input handleEvent:NSStreamEventHasBytesAvailable];
  [self assertTrue:[_telnet isInCommand]];
}

@end

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

- (void) testEmbeddedNOP
{
  char cstring[4];
  cstring[0] = 'a';
  cstring[1] = TEL_IAC;
  cstring[2] = TEL_NOP;
  cstring[3] = 'b';
  NSData *data = [NSData dataWithBytes:(const void *)cstring length:4];
  NSInputStream *input = [NSInputStream inputStreamWithData:data];
  [input open];
  
  [_telnet stream:input handleEvent:NSStreamEventHasBytesAvailable];
  NSString *telnetString = [_telnet read];
  [self assert:telnetString equals:@"ab"];
}

- (void) testWrite
{
  uint8_t outputBuffer[MUTelnetBufferMax];
  bzero(outputBuffer, MUTelnetBufferMax);
  NSOutputStream *output = [NSOutputStream outputStreamToBuffer:outputBuffer
                                                       capacity:MUTelnetBufferMax];
  [output open];
  [_telnet write:@"Foo"];
  [_telnet stream:output
      handleEvent:NSStreamEventHasSpaceAvailable];
  NSString *outputString = [NSString stringWithCString:(const char *)outputBuffer];
  [self assert:outputString equals:@"Foo"];
}

- (void) testConsecutiveWrites
{
  uint8_t outputBuffer[MUTelnetBufferMax];
  bzero(outputBuffer, MUTelnetBufferMax);
  NSOutputStream *output = [NSOutputStream outputStreamToBuffer:outputBuffer
                                                       capacity:MUTelnetBufferMax];
  [output open];
  [_telnet write:@"Foo"];
  [_telnet write:@"Bar"];
  [_telnet stream:output
      handleEvent:NSStreamEventHasSpaceAvailable];
  NSString *outputString = [NSString stringWithCString:(const char *)outputBuffer];
  [self assert:outputString equals:@"FooBar"];
  [_telnet stream:output
      handleEvent:NSStreamEventHasSpaceAvailable];
  outputString = [NSString stringWithCString:(const char *)outputBuffer];
  [self assert:outputString equals:@"FooBar"];
}

@end

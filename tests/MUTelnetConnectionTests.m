//
//  MUTelnetConnectionTests.m
//  Koan
//
//  Created by Samuel on 9/16/04.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import "MUTelnetConnectionTests.h"
#import "MUTelnetConnection.h"

@interface MUTelnetConnectionTests (HelperMethods)
- (void) negotiationCommand:(int)byteRead response:(int)byteWritten;
- (NSInputStream *) openInputStreamWithBytes:(const void *)bytes length:(int)length;
- (NSOutputStream *)openOutputStreamWithBuffer:(void *)buffer maxLength:(int)maxLength;
@end

@implementation MUTelnetConnectionTests (HelperMethods)
- (void) negotiationCommand:(int)byteRead response:(int)byteWritten
{
  char cstring[3];
  cstring[0] = TEL_IAC;
  cstring[1] = byteRead;
  cstring[2] = 1; // This is the option code for ECHO
  NSInputStream *input = [self openInputStreamWithBytes:(const void *)cstring length:3];
  
  uint8_t outputBuffer[MUTelnetBufferMax];
  NSOutputStream *output = [self openOutputStreamWithBuffer:outputBuffer
                                                  maxLength:MUTelnetBufferMax];
  
  [_telnet stream:input handleEvent:NSStreamEventHasBytesAvailable];
  [_telnet stream:output handleEvent:NSStreamEventHasSpaceAvailable];
  [self assertTrue:outputBuffer[0] == TEL_IAC message:@"First byte"];
  [self assertTrue:outputBuffer[1] == byteWritten message:@"Second byte"];
  NSString *telnetString = [_telnet read];
  [self assert:telnetString equals:@""];  
}

- (NSOutputStream *)openOutputStreamWithBuffer:(void *)buffer maxLength:(int)maxLength
{
  bzero(buffer, maxLength);
  NSOutputStream *output = [NSOutputStream outputStreamToBuffer:buffer
                                                       capacity:maxLength];
  [output open];
  return output;
}

- (NSInputStream *) openInputStreamWithBytes:(const void *)bytes length:(int)length
{
  NSData *data = [NSData dataWithBytes:(const void *)bytes length:length];
  NSInputStream *input = [NSInputStream inputStreamWithData:data];
  [input open];
  return input;
}

@end

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
  NSInputStream *input = [self openInputStreamWithBytes:(const void *)"Foo" length:3];
  [_telnet stream:input handleEvent:NSStreamEventHasBytesAvailable];
  NSString *telnetString = [_telnet read];
  [self assert:telnetString equals:@"Foo"];
}

- (void) testConsecutiveReads
{
  NSInputStream *input = [self openInputStreamWithBytes:(const void *)"Foo" length:3];  
  [_telnet stream:input handleEvent:NSStreamEventHasBytesAvailable];
  input = [self openInputStreamWithBytes:(const void *)"Bar" length:3];
  [_telnet stream:input handleEvent:NSStreamEventHasBytesAvailable];
  NSString *telnetString = [_telnet read];
  [self assert:telnetString equals:@"FooBar"];
  telnetString = [_telnet read];
  [self assert:telnetString equals:@""];
  
  [_telnet stream:input handleEvent:NSStreamEventHasBytesAvailable];
  input = [self openInputStreamWithBytes:(const void *)"Baz" length:3];
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
  NSInputStream *input = [self openInputStreamWithBytes:(const void *)cstring length:4];
  
  [_telnet stream:input handleEvent:NSStreamEventHasBytesAvailable];
  NSString *telnetString = [_telnet read];
  [self assert:telnetString equals:@"ab"];
}

- (void) testWrite
{
  uint8_t outputBuffer[MUTelnetBufferMax];
  NSOutputStream *output = [self openOutputStreamWithBuffer:outputBuffer
                                                  maxLength:MUTelnetBufferMax];
  [_telnet writeString:@"Foo"];
  [_telnet stream:output
      handleEvent:NSStreamEventHasSpaceAvailable];
  NSString *outputString = [NSString stringWithCString:(const char *)outputBuffer];
  [self assert:outputString equals:@"Foo"];
}

- (void) testConsecutiveWrites
{
  uint8_t outputBuffer[MUTelnetBufferMax];
  NSOutputStream *output = [self openOutputStreamWithBuffer:outputBuffer
                                                  maxLength:MUTelnetBufferMax];
  [_telnet writeString:@"Foo"];
  [_telnet writeString:@"Bar"];
  [_telnet stream:output
      handleEvent:NSStreamEventHasSpaceAvailable];
  NSString *outputString = [NSString stringWithCString:(const char *)outputBuffer];
  [self assert:outputString equals:@"FooBar"];
  [_telnet stream:output
      handleEvent:NSStreamEventHasSpaceAvailable];
  outputString = [NSString stringWithCString:(const char *)outputBuffer];
  [self assert:outputString equals:@"FooBar"];
}

- (void) testWillDont
{
  [self negotiationCommand:TEL_WILL response:TEL_DONT];
}

- (void) testWontDont
{
  [self negotiationCommand:TEL_WONT response:TEL_DONT];
}

- (void) testDoWont
{
  [self negotiationCommand:TEL_DO response:TEL_WONT];
}

- (void) testDontWont
{
  [self negotiationCommand:TEL_DONT response:TEL_WONT];
}

@end

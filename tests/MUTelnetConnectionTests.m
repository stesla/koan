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
- (NSInputStream *) openInputStreamWithBytes:(const char *)bytes;
- (NSOutputStream *)openOutputStreamWithBuffer:(void *)buffer maxLength:(int)maxLength;
- (NSData *) dataWithCString:(const char *)cstring;
@end

@implementation MUTelnetConnectionTests (HelperMethods)
- (void) negotiationCommand:(int)byteRead response:(int)byteWritten
{
  char cstring[3];
  cstring[0] = TEL_IAC;
  cstring[1] = byteRead;
  cstring[2] = 1; // This is the option code for ECHO
  cstring[3] = 0;
  NSInputStream *input = [self openInputStreamWithBytes:cstring];

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

- (NSInputStream *) openInputStreamWithBytes:(const char *)bytes
{
  NSData *data = [self dataWithCString:bytes];
  NSInputStream *input = [NSInputStream inputStreamWithData:data];
  [input open];
  return input;
}

- (NSData *) dataWithCString:(const char *)cstring
{
  return [NSData dataWithBytes:(const void *)cstring 
                        length:strlen(cstring)];
}


@end

@implementation MUTelnetConnectionTests

- (void) setUp
{
  _telnet = [[MUTelnetConnection alloc] init];
  _lineRead = @"";
  [_telnet setDelegate:self];
}

- (void) tearDown
{
  [_telnet release];
}

- (void) testRead
{
  NSInputStream *input = [self openInputStreamWithBytes:"Foo"];
  [_telnet stream:input handleEvent:NSStreamEventHasBytesAvailable];
  NSString *telnetString = [_telnet read];
  [self assert:telnetString equals:@"Foo"];
}

- (void) testConsecutiveReads
{
  NSInputStream *input = [self openInputStreamWithBytes:"Foo"];
  [_telnet stream:input handleEvent:NSStreamEventHasBytesAvailable];
  input = [self openInputStreamWithBytes:"Bar"];
  [_telnet stream:input handleEvent:NSStreamEventHasBytesAvailable];
  NSString *telnetString = [_telnet read];
  [self assert:telnetString equals:@"FooBar"];
  telnetString = [_telnet read];
  [self assert:telnetString equals:@""];

  [_telnet stream:input handleEvent:NSStreamEventHasBytesAvailable];
  input = [self openInputStreamWithBytes:"Baz"];
  [_telnet stream:input handleEvent:NSStreamEventHasBytesAvailable];
  telnetString = [_telnet read];
  [self assert:telnetString equals:@"Baz"];
}

- (void) testIsInCommand
{
  char cstring[3];
  cstring[0] = 'a';
  cstring[1] = TEL_IAC;
  cstring[2] = 0;
  NSData *data = [NSData dataWithBytes:(const void *)cstring length:2];
  NSInputStream *input = [NSInputStream inputStreamWithData:data];
  [input open];

  [_telnet stream:input handleEvent:NSStreamEventHasBytesAvailable];
  [self assertTrue:[_telnet isInCommand]];
}

- (void) testEmbeddedNOP
{
  char cstring[5];
  cstring[0] = 'a';
  cstring[1] = TEL_IAC;
  cstring[2] = TEL_NOP;
  cstring[3] = 'b';
  cstring[4] = 0;
  NSInputStream *input = [self openInputStreamWithBytes:cstring];

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

- (void) telnetDidReadLine:(MUTelnetConnection *)telnet
{
  _lineRead = [telnet read];
}

- (void) testDidReadLine
{
  NSData *data = [self dataWithCString:"Fo"];
  NSInputStream *input = [NSInputStream inputStreamWithData:data];
  [input open];

  [_telnet stream:input handleEvent:NSStreamEventHasBytesAvailable];
  [self assert:_lineRead equals:@""];
  
  data = [self dataWithCString:"o\n"];
  input = [NSInputStream inputStreamWithData:data];
  [input open];
  [_telnet stream:input handleEvent:NSStreamEventHasBytesAvailable];
  [self assert:_lineRead equals:@"Foo\n"];
  [self assert:[_telnet read] equals:@""];
  
  
  data = [self dataWithCString:"bar\n"];
  input = [NSInputStream inputStreamWithData:data];
  [input open];
  [_telnet stream:input handleEvent:NSStreamEventHasBytesAvailable];
  [self assert:_lineRead equals:@"bar\n"];
}



@end

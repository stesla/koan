//
// J3SOCKSPrimitiveTests.m
//
// Copyright (c) 2007 3James Software.
//

#import "J3SOCKSPrimitiveTests.h"

#import "J3ByteSource.h"
#import "J3ReadBuffer.h"
#import "J3SocksAuthentication.h"
#import "J3SocksConstants.h"
#import "J3SocksMethodSelection.h"
#import "J3SocksRequest.h"
#import "J3WriteBuffer.h"

@interface J3MockByteSource : J3ReadBuffer <J3ByteSource>

@end

#pragma mark -

@implementation J3MockByteSource

- (void) appendBytes: (const uint8_t *) bytes length: (unsigned) length
{
  [self appendData: [NSData dataWithBytes: bytes length: length]];
}

- (unsigned) availableBytes
{
  return [self length];
}

- (BOOL) hasDataAvailable
{
  return [self availableBytes] > 0;
}

- (void) poll
{
  ;
}

- (NSData *) readExactlyLength: (size_t) length;
{
  return [self readUpToLength: length];
}

- (NSData *) readUpToLength: (size_t) length
{
  return [self dataByConsumingBytesToIndex: length];
}

@end

#pragma mark -

@interface J3SOCKSPrimitiveTests (Private)

- (void) assertObject: (id) selection writes: (NSString *) output;
- (void) setReadString: (NSString *) newString;

@end

#pragma mark -

@implementation J3SOCKSPrimitiveTests

- (void) setUp
{
  buffer = [[J3WriteBuffer alloc] init];
  readString = nil;
}

- (void) tearDown
{
  [buffer release];
  [readString release];
}

- (void) testMethodSelection
{
  J3SocksMethodSelection *selection = [[[J3SocksMethodSelection alloc] init] autorelease];
  const char expected1[] = {0x05, 0x01, 0x00};
  const char expected2[] = {0x05, 0x02, 0x00, 0x02};
  
  [buffer clear];
  [selection appendToBuffer: buffer];
  
  NSString *output = [buffer stringValue];
  for (unsigned i = 0; i < [buffer length]; i++)
    [self assertInt: (int) [output characterAtIndex: i] equals: expected1[i]];
   
  [selection addMethod: J3SocksUsernamePassword];

  [buffer clear];
  [selection appendToBuffer: buffer];
  output = [buffer stringValue];
  for (unsigned j = 0; j < [buffer length]; j++)
    [self assertInt: (int) [output characterAtIndex: j] equals: expected2[j]];
}

- (void) testSelectMethod
{
  J3SocksMethodSelection *selection = [[[J3SocksMethodSelection alloc] init] autorelease];
  J3MockByteSource *source = [[[J3MockByteSource alloc] init] autorelease];
  
  [source setDelegate: self];
  [selection addMethod: J3SocksUsernamePassword];
  [self assertInt: [selection method] equals: J3SocksNoAuthentication];
  [source appendBytes: (uint8_t *) "\x05\x02" length: 2];
  [selection parseResponseFromByteSource: source];
  [self assertInt: [selection method] equals: J3SocksUsernamePassword];
}

- (void) testRequest
{
  J3SocksRequest *request = [[[J3SocksRequest alloc] initWithHostname: @"example.com" port: 0xABCD] autorelease];
  uint8_t expected[18] = {J3SocksVersion, J3SocksConnect, 0, 3, 11, 'e', 'x', 'a', 'm', 'p', 'l', 'e', '.', 'c', 'o', 'm', 0xAB, 0xCD};
  
  [buffer clear];
  [request appendToBuffer: buffer];
  
  NSData *data = [buffer dataValue];
  [self assertInt: [data length] equals: 18]; // same as expected length above
  for (unsigned i = 0; i < 18; i++)
    [self assertInt: ((uint8_t *) [data bytes])[i] equals: expected[i]];
}

- (void) testReplyWithDomainName
{
  J3SocksRequest *request = [[[J3SocksRequest alloc] initWithHostname: @"example.com" port: 0xABCD] autorelease];
  J3MockByteSource *source = [[[J3MockByteSource alloc] init] autorelease];
  uint8_t reply[18] = {J3SocksVersion, J3SocksConnectionNotAllowed, 0, J3SocksDomainName, 11, 'e', 'x', 'a', 'm', 'p', 'l', 'e', '.', 'c', 'o', 'm', 0xAB, 0xCD};
  
  [source setDelegate: self];
  [self assertInt: [request reply] equals: J3SocksNoReply];
  [source appendBytes: reply length: 18];
  [source appendBytes: (uint8_t *) "foo" length: 3];
  [request parseReplyFromByteSource: source];
  [source interpretBufferAsString];
  [self assert: readString equals: @"foo"];
  [self assertInt: [request reply] equals: J3SocksConnectionNotAllowed];
}

- (void) testReplyWithIPV4
{
  J3SocksRequest *request = [[[J3SocksRequest alloc] initWithHostname: @"example.com" port: 0xABCD] autorelease];
  J3MockByteSource *source = [[[J3MockByteSource alloc] init] autorelease];
  uint8_t reply[10] = {J3SocksVersion, J3SocksConnectionNotAllowed, 0, J3SocksIPV4, 10, 1, 2, 3, 0xAB, 0xCD};
  
  [source setDelegate: self];
  [self assertInt: [request reply] equals: J3SocksNoReply];
  [source appendBytes: reply length: 10];
  [source appendBytes: (uint8_t *) "foo" length: 3];
  [request parseReplyFromByteSource: source];
  [source interpretBufferAsString];
  [self assert: readString equals: @"foo"];
  [self assertInt: [request reply] equals: J3SocksConnectionNotAllowed];
}

- (void) testReplyWithIPV6
{
  J3SocksRequest *request = [[[J3SocksRequest alloc] initWithHostname: @"example.com" port: 0xABCD] autorelease];
  J3MockByteSource *source = [[[J3MockByteSource alloc] init] autorelease];
  uint8_t reply[22] = {J3SocksVersion, J3SocksConnectionNotAllowed, 0, J3SocksIPV6, 0xFE, 0xC0, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0xAB, 0xCD};
  
  [source setDelegate: self];
  [self assertInt: [request reply] equals: J3SocksNoReply];
  [source appendBytes: reply length: 22];
  [source appendBytes: (uint8_t *) "foo" length: 3];
  [request parseReplyFromByteSource: source];
  [source interpretBufferAsString];
  [self assert: readString equals: @"foo"];
  [self assertInt: [request reply] equals: J3SocksConnectionNotAllowed];
}

- (void) testAuthentication
{
  J3SocksAuthentication *auth = [[[J3SocksAuthentication alloc] initWithUsername: @"bob" password: @"barfoo"] autorelease];
  uint8_t expected[12] = {J3SocksUsernamePasswordVersion, 3, 'b', 'o', 'b', 6, 'b', 'a', 'r', 'f', 'o', 'o'};
  
  [buffer clear];
  [auth appendToBuffer: buffer];
  
  NSData *data = [buffer dataValue];
  [self assertInt: [data length] equals: 12]; // same as expected length above
  for (unsigned i = 0; i < 12; i++)
    [self assertInt: ((uint8_t *) [data bytes])[i] equals: expected[i]];
}

- (void) testAuthenticationReply
{
  J3SocksAuthentication *auth = [[[J3SocksAuthentication alloc] initWithUsername: @"bob" password: @"barfoo"] autorelease];
  J3MockByteSource *source = [[[J3MockByteSource alloc] init] autorelease];
  
  [source setDelegate: self];
  [self assertFalse: [auth authenticated]];
  [source appendByte: 1];
  [source appendByte: 0];
  [auth parseReplyFromSource: source];
  [self assertTrue: [auth authenticated]];
  [source appendByte: 1];
  [source appendByte: 11]; // non-zero
  [auth parseReplyFromSource: source];  
  [self assertFalse: [auth authenticated]];
}

#pragma mark -
#pragma mark J3ReadBuffer delegate

- (void) readBufferDidProvideString: (NSNotification *) notification
{
  [self setReadString: [[notification userInfo] objectForKey: @"string"]];
}

@end

#pragma mark -

@implementation J3SOCKSPrimitiveTests (Private)

- (void) assertObject: (id) object writes: (NSString *) output
{
  [buffer clear];
  [object appendToBuffer: buffer];
  [self assert: [buffer stringValue] equals: output];  
}

- (void) setReadString: (NSString *) newString
{
  [self at: &readString put: newString];
}

@end


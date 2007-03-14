//
// J3TestSocksPrimitives.m
//
// Copyright (c) 2005 3James Software
//

#import "J3Buffer.h"
#import "J3ByteSource.h"
#import "J3TestSocksPrimitives.h"
#import "J3SocksAuthentication.h"
#import "J3SocksConstants.h"
#import "J3SocksMethodSelection.h"
#import "J3SocksRequest.h"

@interface J3MockByteSource : J3Buffer <J3ByteSource>
{
  unsigned bytesToRead;
}

- (void) setBytesToRead:(unsigned)value;

@end

@implementation J3MockByteSource

- (BOOL) hasDataAvailable;
{
  return [self length] > 0;
}

- (unsigned) read:(uint8_t *)buffer maxLength:(unsigned)length;
{
  unsigned lengthToRead = length;
  if (bytesToRead > 0)
    lengthToRead = length < bytesToRead ? length : bytesToRead;

  [[self dataValue] getBytes:buffer length:lengthToRead];
  [self removeDataUpTo:lengthToRead];
  return [self length] > lengthToRead ? lengthToRead : [self length];
}

- (void) setBytesToRead:(unsigned)value;
{
  bytesToRead = value;
}

@end

@interface J3TestSocksPrimitives (Private)

- (void) assertObject:(id)selection writes:(NSString *)output;

@end

#pragma mark -

@implementation J3TestSocksPrimitives

- (void) setUp
{
  buffer = [[J3Buffer alloc] init];
}

- (void) tearDown
{
  [buffer release];
}

- (void) testMethodSelection;
{
  J3SocksMethodSelection *selection = [[[J3SocksMethodSelection alloc] init] autorelease];
  NSString *output;
  unsigned i;
  const char expected1[] = {0x05, 0x01, 0x00};
  const char expected2[] = {0x05, 0x02, 0x00, 0x02};
  
  [buffer clear];
  [selection appendToBuffer:buffer];
  output = [buffer stringValue];
  for (i = 0; i < [buffer length]; ++i)
    [self assertInt:(int)[output characterAtIndex:i] equals:expected1[i]];
   
  [selection addMethod:J3SocksUsernamePassword];

  [buffer clear];
  [selection appendToBuffer:buffer];
  output = [buffer stringValue];
  for (i = 0; i < [buffer length]; ++i)
    [self assertInt:(int)[output characterAtIndex:i] equals:expected2[i]];
}

- (void) testSelectMethod;
{
  J3SocksMethodSelection *selection = [[[J3SocksMethodSelection alloc] init] autorelease];
  J3MockByteSource *source = [[[J3MockByteSource alloc] init] autorelease];
  [selection addMethod:J3SocksUsernamePassword];
  [self assertInt:[selection method] equals:J3SocksNoAuthentication];
  [source appendString:@"\x05\x02"];
  [selection parseResponseFromByteSource:source];
  [self assertInt:[selection method] equals:J3SocksUsernamePassword];
}

- (void) testSelectMethodOneByteAtATime;
{
  J3SocksMethodSelection *selection = [[[J3SocksMethodSelection alloc] init] autorelease];
  J3MockByteSource *source = [[[J3MockByteSource alloc] init] autorelease];
  [selection addMethod:J3SocksUsernamePassword];
  [source appendString:@"\x05\x02"];
  [source setBytesToRead:1];
  [selection parseResponseFromByteSource:source];
  [self assertInt:[selection method] equals:J3SocksUsernamePassword];  
}

- (void) testRequest;
{
  J3SocksRequest *request = [[[J3SocksRequest alloc] initWithHostname:@"example.com" port:0xABCD] autorelease];
  uint8_t expected[18] = {J3SocksVersion, J3SocksConnect, 0, 3, 11, 'e', 'x', 'a', 'm', 'p', 'l', 'e', '.', 'c', 'o', 'm', 0xAB, 0xCD};
  NSData * data;
  int i;
  
  [buffer clear];
  [request appendToBuffer:buffer];
  data = [buffer dataValue];
  [self assertInt:[data length] equals:18]; // same as expected length above
  for (i = 0; i < 18; ++i)
    [self assertInt:((uint8_t *)[data bytes])[i] equals:expected[i]];
}

- (void) testReplyWithDomainName;
{
  J3SocksRequest *request = [[[J3SocksRequest alloc] initWithHostname:@"example.com" port:0xABCD] autorelease];
  J3MockByteSource *source = [[[J3MockByteSource alloc] init] autorelease];
  uint8_t reply[18] = {J3SocksVersion, J3SocksConnectionNotAllowed, 0, J3SocksDomainName, 11, 'e', 'x', 'a', 'm', 'p', 'l', 'e', '.', 'c', 'o', 'm', 0xAB, 0xCD};
  int i;
  
  [self assertInt:[request reply] equals:J3SocksNoReply];
  [source appendBytes:reply length:18];
  [source appendString:@"foo"];
  [request parseReplyFromByteSource:source];
  [self assert:[source stringValue] equals:@"foo"];
  [self assertInt:[request reply] equals:J3SocksConnectionNotAllowed];
}

- (void) testReplyWithIPV4;
{
  J3SocksRequest *request = [[[J3SocksRequest alloc] initWithHostname:@"example.com" port:0xABCD] autorelease];
  J3MockByteSource *source = [[[J3MockByteSource alloc] init] autorelease];
  uint8_t reply[10] = {J3SocksVersion, J3SocksConnectionNotAllowed, 0, J3SocksIPV4, 10, 1, 2, 3, 0xAB, 0xCD};
  int i;
  
  [self assertInt:[request reply] equals:J3SocksNoReply];
  [source appendBytes:reply length:10];
  [source appendString:@"foo"];
  [request parseReplyFromByteSource:source];
  [self assert:[source stringValue] equals:@"foo"];
  [self assertInt:[request reply] equals:J3SocksConnectionNotAllowed];
}

- (void) testReplyWithIPV6;
{
  J3SocksRequest *request = [[[J3SocksRequest alloc] initWithHostname:@"example.com" port:0xABCD] autorelease];
  J3MockByteSource *source = [[[J3MockByteSource alloc] init] autorelease];
  uint8_t reply[22] = {J3SocksVersion, J3SocksConnectionNotAllowed, 0, J3SocksIPV6, 0xFE, 0xC0, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0xAB, 0xCD};
  int i;
  
  [self assertInt:[request reply] equals:J3SocksNoReply];
  [source appendBytes:reply length:22];
  [source appendString:@"foo"];
  [request parseReplyFromByteSource:source];
  [self assert:[source stringValue] equals:@"foo"];
  [self assertInt:[request reply] equals:J3SocksConnectionNotAllowed];
}

- (void) testAuthentication;
{
  J3SocksAuthentication *auth = [[[J3SocksAuthentication alloc] initWithUsername:@"bob" password:@"barfoo"] autorelease];
  uint8_t expected[12] = {J3SocksUsernamePasswordVersion, 3, 'b', 'o', 'b', 6, 'b', 'a', 'r', 'f', 'o', 'o'};
  NSData * data;
  int i;
  
  [buffer clear];
  [auth appendToBuffer:buffer];
  data = [buffer dataValue];
  [self assertInt:[data length] equals:12]; // same as expected length above
  for (i = 0; i < 12; ++i)
    [self assertInt:((uint8_t *)[data bytes])[i] equals:expected[i]];
}

- (void) testAuthenticationReply;
{
  J3SocksAuthentication *auth = [[[J3SocksAuthentication alloc] initWithUsername:@"bob" password:@"barfoo"] autorelease];
  J3MockByteSource *source = [[[J3MockByteSource alloc] init] autorelease];

  [self assertFalse:[auth authenticated]];
  [source append:1];
  [source append:0];
  [auth parseReplyFromSource:source];
  [self assertTrue:[auth authenticated]];
  [source append:1];
  [source append:11]; // non-zero
  [auth parseReplyFromSource:source];  
  [self assertFalse:[auth authenticated]];
}


@end

#pragma mark -

@implementation J3TestSocksPrimitives (Private)

- (void) assertObject:(id)object writes:(NSString *)output;
{
  [buffer clear];
  [object appendToBuffer:buffer];
  [self assert:[buffer stringValue] equals:output];  
}

@end


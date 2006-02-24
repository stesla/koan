//
// J3TestSocksPrimitives.m
//
// Copyright (c) 2005 3James Software
//

#import "J3Buffer.h"
#import "J3ByteSource.h"
#import "J3TestSocksPrimitives.h"
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
  [self assertObject:selection writes:@"\x05\x01\x00"];
  [selection addMethod:J3SocksUsernamePassword];
  [self assertObject:selection writes:@"\x05\x02\x00\x02"];
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
  uint8_t expected[18] = {5, 1, 0, 3, 11, 'e', 'x', 'a', 'm', 'p', 'l', 'e', '.', 'c', 'o', 'm', 0xAB, 0xCD};
  NSData * data;
  int i;
  
  [buffer clear];
  [request appendToBuffer:buffer];
  data = [buffer dataValue];
  [self assertInt:[data length] equals:18]; // same as expected length above
  for (i = 0; i < 18; ++i)
    [self assertInt:((uint8_t *)[data bytes])[i] equals:expected[i]];
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


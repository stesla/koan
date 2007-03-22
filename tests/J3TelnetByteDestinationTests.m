//
//  J3TelnetByteDestination.m
//
// Copyright (c) 2007 3James Software
//

#import "J3TelnetByteDestinationTests.h"

#define DEFAULT_MAX_BYTES 255

@interface J3TelnetByteDestinationTests (Private)

- (void) assertOutputContainsOnlyBytes: (const uint8_t *) bytes length: (unsigned) length;
- (void) hasSpaceAvailable: (BOOL) value;
- (void) maxBytesPerWrite: (unsigned) value;

@end

@implementation J3TelnetByteDestinationTests

- (void) setUp;
{
  output = [[NSMutableData data] retain];
  destination = [[[J3TelnetByteDestination alloc] init] autorelease];
  [destination setDestination: self];
  [self hasSpaceAvailable: true];
  [self maxBytesPerWrite: DEFAULT_MAX_BYTES];
}

- (void) tearDown;
{
  [output release];
  [super tearDown];
}

- (void) testWrite;
{
  [destination write: (uint8_t *) "abc" length: 3];
  [self assertOutputContainsOnlyBytes: (const uint8_t *) "abc" length: 3];
}

- (void) testHasSpaceAvailable;
{
  [self hasSpaceAvailable: true];
  [self assertTrue: [destination hasSpaceAvailable] message: @"Should not have space"];
  [self hasSpaceAvailable: false];
  [self assertFalse: [destination hasSpaceAvailable] message: @"Should have space"];
}

- (void) testNilDestination;
{
  [destination setDestination: nil];
  [self assertFalse: [destination hasSpaceAvailable] message: @"no space!"];
  [self assertInt: [destination write: (uint8_t *) "foo" length: 3] equals: 0 message: @"Should say it did not write bytes"];
}

- (void) testWriteWithDestinationThatDoesNotWriteEverything;
{
  [self maxBytesPerWrite: 3];
  [self assertInt: [destination write: (uint8_t *) "foobar" length: 6] equals: 3];
  [self assertOutputContainsOnlyBytes: (uint8_t *) "foo" length: 3];
  [self assertInt: numberOfWrites equals: 1];
}

- (void) testWillActuallyWriteEvenIfDestinationHasNoSpaceAvailable;
{
  // Note, this is a terrible abuse of the mocking that I'm doing.  In real life the call to
  // -write:length: would block on IO.  Because we are faking it, it won't do that, and will
  // still pass it on. -- ST
  [self hasSpaceAvailable: false];
  [destination write: (uint8_t *) "foo" length: 3];
  [self assertOutputContainsOnlyBytes: (uint8_t *) "foo" length: 3];
}

#pragma mark -
#pragma mark J3ByteDestination protocol

- (BOOL) hasSpaceAvailable;
{
  return hasSpaceAvailable;
}

- (unsigned) write: (const uint8_t *) bytes length: (unsigned) length;
{
  unsigned lengthToWrite = maxBytesPerWrite < length ? maxBytesPerWrite : length;
  [output appendBytes: bytes length: lengthToWrite];
  numberOfWrites++;
  return lengthToWrite;  
}

@end

#pragma mark -

@implementation J3TelnetByteDestinationTests (Private)

- (void) assertOutputContainsOnlyBytes:(const uint8_t *) bytes length:(unsigned) length;
{
  if (length != [output length])
  {
    [self fail: [NSString stringWithFormat: @"Expected output to have [%d] bytes, but it only had [%d].", length, [output length]]];
    return;
  }
  for (int i = 0; i < length; ++i)
    [self assertInt: ((uint8_t *) [output bytes])[i] equals: bytes[i]];
}

- (void) hasSpaceAvailable: (BOOL) value;
{
  hasSpaceAvailable = value;
}

- (void) maxBytesPerWrite: (unsigned) value;
{
  maxBytesPerWrite = value;
}

@end

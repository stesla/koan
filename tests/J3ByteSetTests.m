//
//  J3ByteSetTests.m
//  Koan
//
//  Created by Samuel on 4/19/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "J3ByteSetTests.h"
#import "J3ByteSet.h"

@implementation J3ByteSetTests

- (void) testEmptySet
{
  J3ByteSet *byteSet = [J3ByteSet byteSet];
  for (unsigned i = 0; i <= UINT8_MAX; ++i)
    [self assertFalse: [byteSet containsByte: i] message: [NSString stringWithFormat:@"%d should not have been included",i]];
}

- (void) testAddByte
{
  J3ByteSet *byteSet = [J3ByteSet byteSet];
  [byteSet addByte: 42];
  [byteSet addByte: 31];
  [self assertTrue: [byteSet containsByte: 42] message: @"Expected to contain 42"];
  [self assertTrue: [byteSet containsByte: 31] message: @"Expected to contain 31"];
}

- (void) testAddBytes
{
  J3ByteSet *byteSet = [J3ByteSet byteSetWithBytes: 0, 42, 27, -1];
  [byteSet addBytes: 3, 4, 5, -1];
  [self assertTrue: [byteSet containsByte: 0] message: @"Expected to contain 0"];
  [self assertTrue: [byteSet containsByte: 42] message: @"Expected to contain 42"];
  [self assertTrue: [byteSet containsByte: 27] message: @"Expected to contain 27"];
  [self assertTrue: [byteSet containsByte: 3] message: @"Expected to contain 3"];
  [self assertTrue: [byteSet containsByte: 4] message: @"Expected to contain 4"];
  [self assertTrue: [byteSet containsByte: 5] message: @"Expected to contain 5"];
}

- (void) testInverseSet
{
  J3ByteSet *byteSet = [J3ByteSet byteSetWithBytes: 42, 71, -1];
  J3ByteSet *inverse = [byteSet inverseSet];
  for (unsigned i = 0; i <= UINT8_MAX; ++i)
  {
    if ([byteSet containsByte: i])
      [self assertFalse: [inverse containsByte: i] message: [NSString stringWithFormat: @"Inverse should not contain %d", i]];
    else
      [self assertTrue: [inverse containsByte: i] message: [NSString stringWithFormat: @"Inverse should contain %d", i]];
  }
}

- (void) testDataValue
{
  uint8_t bytes[] = {31, 47, 73};
  J3ByteSet *byteSet = [J3ByteSet byteSetWithBytes: bytes length: 3];
  [self assert: [byteSet dataValue] equals: [NSData dataWithBytes: bytes length: 3]];
}

- (void) testRemoveByte
{
  J3ByteSet *bytes = [J3ByteSet byteSetWithBytes: 42, 53, -1];
  [bytes removeByte: 42];
  [self assertTrue: [bytes containsByte: 53] message: @"53 was removed"];
  [self assertFalse: [bytes containsByte: 42] message: @"42 was not removed"];
}

@end

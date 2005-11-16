//
//  J3WriteBufferTests.m
//  Koan
//
//  Created by Samuel Tesla on 11/15/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "J3WriteBufferTests.h"
#import "J3WriteBuffer.h"

@interface J3WriteBufferTests (Private)
- (NSString *) output;
- (void) setLengthWritten:(unsigned int)length;
- (void) assertOutputIsString:(NSString *)string;
- (void) assertOutputIsString:(NSString *)string lengthWritten:(unsigned int)length;
@end

@implementation J3WriteBufferTests
- (void) setUp
{
  buffer = [[J3WriteBuffer buffer] retain];
  [buffer setByteDestination:self];
  output = [[NSMutableData data] retain];
}

- (void) tearDown
{
  [output release];
  [buffer release];
}

- (void) testWriteToNowhere
{
  [buffer setByteDestination:nil];
  @try
  {
    [buffer write];
    [self fail:@"Write to nil destination should throw exception"];
  }
  @catch (J3WriteBufferException *e)
  {
    [self assertTrue:true];
  }
}

- (void) testWriteAll
{
  [buffer appendString:@"foo"];
  [self assertOutputIsString:@"foo"];
}

- (void) testWriteSome
{
  [buffer appendString:@"123456"];
  [self assertOutputIsString:@"123" lengthWritten:3];
  [self assertOutputIsString:@"123456" lengthWritten:3];
}

- (unsigned int) writeBytes:(const uint8_t *)bytes length:(unsigned int)length;
{
  unsigned int lengthToWrite = lengthWritten < length ? lengthWritten : length;
  [output appendBytes:bytes length:lengthToWrite];
  return lengthToWrite;
}
@end

@implementation J3WriteBufferTests (Private)
- (void) assertOutputIsString:(NSString *)string;
{
  [self assertOutputIsString:string lengthWritten:[string length]];
}

- (void) assertOutputIsString:(NSString *)string lengthWritten:(unsigned int)length;
{
  [self setLengthWritten:length];
  [buffer write];
  [self assert:[self output] equals:string];  
}

- (void) setLengthWritten:(unsigned int)length;
{
  lengthWritten = length;
}

- (NSString *) output;
{
  return [[[NSString alloc] initWithData:output encoding:NSASCIIStringEncoding] autorelease];
}
@end

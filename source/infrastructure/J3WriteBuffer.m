//
// J3WriteBuffer.m
//
// Copyright (c) 2007 3James Software. All rights reserved.
//

#import "J3WriteBuffer.h"
#import "J3ByteDestination.h"

@implementation J3WriteBufferException

@end

#pragma mark -

@interface J3WriteBuffer (Private)

- (void) ensureLastBlockIsBinary;
- (void) ensureLastBlockIsString;
- (void) removeDataUpTo: (unsigned) position;
- (void) setBlocks: (NSArray *) newBlocks;
- (void) write;

@end

#pragma mark -

@implementation J3WriteBuffer

+ (id) buffer
{
  return [[[self alloc] init] autorelease];
}

- (id) init
{
  if (![super init])
    return nil;
  
  blocks = [[NSMutableArray alloc] init];
  lastBlock = nil;
  totalLength = 0;
  
  return self;
}

- (void) dealloc
{
  [blocks release];
  [super dealloc];
}

- (void) setByteDestination: (NSObject <J3ByteDestination> *) object
{
  [object retain];
  [destination release];
  destination = object;
}

#pragma mark -
#pragma mark J3WriteBuffer protocol

- (void) appendByte: (uint8_t) byte
{
  [self ensureLastBlockIsBinary];
  uint8_t bytes[1] = {byte};
  [lastBlock appendBytes: bytes length: 1];
  totalLength++;
}

- (void) appendCharacter: (unichar) character
{
  [self appendString: [NSString stringWithCharacters: &character length: 1]];
}

- (void) appendData: (NSData *) data
{
  [self ensureLastBlockIsBinary];
  [lastBlock appendData: data];
  totalLength += [data length];  
}

- (void) appendLine: (NSString *) line
{
  [self appendString: [NSString stringWithFormat: @"%@\n", line]];
}

- (void) appendString: (NSString *) string
{
  if (!string)
    return;
  [self ensureLastBlockIsString];
  [lastBlock appendString: string];
  totalLength += [string length];
}

- (const uint8_t *) bytes
{
  return [[self dataValue] bytes];
}

- (void) clear
{
  [self setBlocks: [NSArray array]];
  lastBlock = nil;
  totalLength = 0;
}

- (NSData *) dataValue
{
  NSMutableData *accumulator = [NSMutableData data];
  
  for (unsigned i = 0; i < [blocks count]; i++)
  {
    id block = [blocks objectAtIndex: i];
    
    if ([block isKindOfClass: [NSData class]])
      [accumulator appendData: (NSData *) block];
    else if ([block isKindOfClass: [NSString class]])
      [accumulator appendData: [(NSString *) block dataUsingEncoding: NSASCIIStringEncoding allowLossyConversion: YES]];
  }
  
  return accumulator;
}

- (void) flush
{
  while (![self isEmpty])
    [self write];
}

- (BOOL) isEmpty
{
  return [self length] == 0;
}

- (unsigned) length
{
  return totalLength;
}

- (NSString *) stringValue
{
  NSMutableString *accumulator = [NSMutableString string];
  
  for (unsigned i = 0; i < [blocks count]; i++)
  {
    id block = [blocks objectAtIndex: i];
    
    if ([block isKindOfClass: [NSString class]])
      [accumulator appendString: (NSString *) block];
    else if ([block isKindOfClass: [NSData class]])
    {
      NSData *data = (NSData *) block;
      unsigned dataLength = [data length];
      unichar promotionArray[dataLength];
      const uint8_t *byteArray = (const uint8_t *) [data bytes];
      
      for (unsigned j = 0; j < [data length]; j++)
        promotionArray[j] = byteArray[j];
      
      [accumulator appendString: [NSString stringWithCharacters: promotionArray length: dataLength]];
    }
  }
  
  return accumulator;
}

@end

#pragma mark -

@implementation J3WriteBuffer (Private)

- (void) ensureLastBlockIsBinary
{
  if (!lastBlock || !lastBlockIsBinary)
  {
    lastBlock = [NSMutableData data];
    [blocks addObject: lastBlock];
    lastBlockIsBinary = YES;
  }
}

- (void) ensureLastBlockIsString
{
  if (!lastBlock || lastBlockIsBinary)
  {
    lastBlock = [NSMutableString string];
    [blocks addObject: lastBlock];
    lastBlockIsBinary = NO;
  }  
}

- (void) removeDataUpTo: (unsigned) position
{
  while (position > 0 && [blocks count] > 0)
  {
    id lowestBlock = [blocks objectAtIndex: 0];
    
    if (position >= [lowestBlock length])
    {
      position -= [lowestBlock length];
      totalLength -= [lowestBlock length];
      if (lowestBlock == lastBlock)
        lastBlock = nil;
      [blocks removeObjectAtIndex: 0];
    }
    else
    {
      if ([lowestBlock isKindOfClass: [NSMutableData class]])
      {
        [(NSMutableData *) lowestBlock setData:
          [(NSMutableData *) lowestBlock subdataWithRange: NSMakeRange (position, [lowestBlock length] - position)]];
        totalLength -= position;
        position = 0;
      }
      else if ([lowestBlock isKindOfClass: [NSMutableString class]])
      {
        [(NSMutableString *) lowestBlock setString:
          [(NSMutableString *) lowestBlock substringFromIndex: position]];
        totalLength -= position;
        position = 0;
      }
    }
  }
}

- (void) setBlocks: (NSArray *) newBlocks
{
  if (blocks == newBlocks)
    return;
  [blocks release];
  blocks = [newBlocks mutableCopy];
}

- (void) write
{
  unsigned bytesWritten;
  
  if (!destination)
    @throw [J3WriteBufferException exceptionWithName: @"" reason: @"Must provide destination" userInfo: nil];
  
  bytesWritten = [destination write: [self dataValue]];
  
  if (bytesWritten == [self length])
    [self clear];
  else
    [self removeDataUpTo: bytesWritten];
}

@end

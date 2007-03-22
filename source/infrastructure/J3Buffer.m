//
// J3Buffer.m
//
// Copyright (c) 2005, 2006, 2007 3James Software
//

#import "J3Buffer.h"

@interface J3Buffer (Private)

- (void) setBlocks: (NSArray *) newBlocks;

@end

#pragma mark -

@implementation J3Buffer

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

- (void) removeDataUpTo: (unsigned) position
{
  while (position > 0 && [blocks count] > 0)
  {
    id lowestBlock = [blocks objectAtIndex: 0];
    unsigned MONITOR = [lowestBlock length];
    
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

#pragma mark -
#pragma mark J3Buffer protocol

- (void) appendByte: (uint8_t) byte
{
  uint8_t bytes[1] = {byte};
  [self appendBytes: bytes length: 1];
}

- (void) appendBytes: (const uint8_t *) bytes length: (unsigned) length;
{
  if (!lastBlock || !lastBlockIsBinary)
  {
    lastBlock = [NSMutableData data];
    [blocks addObject: lastBlock];
    lastBlockIsBinary = YES;
  }
  
  [lastBlock appendData: [NSData dataWithBytes: bytes length: length]];
  totalLength += length;
}

- (void) appendCharacter: (unichar) character
{
  [self appendString: [NSString stringWithCharacters: &character length: 1]];
}

- (void) appendLine: (NSString *) line
{
  [self appendString: [NSString stringWithFormat: @"%@\n", line]];
}

- (void) appendString: (NSString *) string
{
  if (!string)
    return;
  
  if (!lastBlock || lastBlockIsBinary)
  {
    lastBlock = [NSMutableString string];
    [blocks addObject: lastBlock];
    lastBlockIsBinary = NO;
  }
  
  [lastBlock appendString: string];
  totalLength += [string length];
}

- (const void *) bytes
{
  return [[self dataValue] bytes];
}

- (void) clear
{
  [self setBlocks: [NSArray array]];
  lastBlock = nil;
  totalLength = 0;
}

- (BOOL) isEmpty
{
  return [self length] == 0;
}

- (unsigned) length
{
  return totalLength;
}

#pragma mark -
#pragma mark Visualizing the data

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

@implementation J3Buffer (Private)

- (void) setBlocks: (NSArray *) newBlocks
{
  if (blocks == newBlocks)
    return;
  [blocks release];
  blocks = [newBlocks mutableCopy];
}

@end

//
// J3Protocol.m
//
// Copyright (c) 2010 3James Software.
//

#import "J3Protocol.h"

@implementation J3ByteProtocolHandler

+ (id) protocolHandler
{
  return [[[self alloc] init] autorelease];
}

- (NSData *) parseData: (NSData *) data
{
  @throw [NSException exceptionWithName: @"SubclassResponsibility"
                                 reason: @"Subclass failed to implement -[parseData:]"
                               userInfo: nil];
}

- (NSData *) preprocessOutput: (NSData *) data
{
  @throw [NSException exceptionWithName: @"SubclassResponsibility"
                                 reason: @"Subclass failed to implement -[preprocessOutput:]"
                               userInfo: nil];
}

@end

#pragma mark -

@implementation J3ProtocolStack

- (id) init
{
  if (!(self = [super init]))
    return nil;
  
  byteProtocolHandlers = [[NSMutableArray alloc] init];
  return self;
}

- (void) dealloc
{
  [byteProtocolHandlers release];
  [super dealloc];
}

- (void) addByteProtocol: (J3ByteProtocolHandler *) protocol
{
  [byteProtocolHandlers addObject: protocol];
}

- (void) clearAllProtocols
{
  [byteProtocolHandlers removeAllObjects];
}

- (NSData *) parseData: (NSData *) data
{
  NSData *workingData = data;
  for (J3ByteProtocolHandler *protocolHandler in [byteProtocolHandlers reverseObjectEnumerator])
  {
    NSData *newWorkingData = [protocolHandler parseData: workingData];
    workingData = newWorkingData;
  }
  
  return workingData;
}

- (NSData *) preprocessOutput: (NSData *) data
{
  NSData *workingData = data;
  for (J3ByteProtocolHandler *protocolHandler in byteProtocolHandlers)
  {
    NSData *newWorkingData = [protocolHandler preprocessOutput: workingData];
    workingData = newWorkingData;
  }
  
  return workingData;
}



@end

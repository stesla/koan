//
// J3Protocol.m
//
// Copyright (c) 2010 3James Software.
//

#import "J3Protocol.h"

@implementation J3ProtocolHandler

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
  
  protocolHandlers = [[NSMutableArray alloc] init];
  return self;
}

- (void) dealloc
{
  [protocolHandlers release];
  [super dealloc];
}

- (void) addProtocol: (J3ProtocolHandler *) protocol
{
  [protocolHandlers addObject: protocol];
}

- (void) clearProtocols
{
  [protocolHandlers removeAllObjects];
}

- (NSData *) parseData: (NSData *) data
{
  NSData *workingData = data;
  for (J3ProtocolHandler *protocolHandler in [protocolHandlers reverseObjectEnumerator])
  {
    NSData *newWorkingData = [protocolHandler parseData: workingData];
    workingData = newWorkingData;
  }
  
  return workingData;
}

- (NSData *) preprocessOutput: (NSData *) data
{
  NSData *workingData = data;
  for (J3ProtocolHandler *protocolHandler in protocolHandlers)
  {
    NSData *newWorkingData = [protocolHandler preprocessOutput: workingData];
    workingData = newWorkingData;
  }
  
  return workingData;
}

@end

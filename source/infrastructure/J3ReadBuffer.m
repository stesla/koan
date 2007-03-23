//
// J3ReadBuffer.m
//
// Copyright (c) 2005, 2006, 2007 3James Software
//

#import "J3ReadBuffer.h"

@interface J3ReadBuffer (Private)

- (void) postDidProvideStringNotificationWithString: (NSString *) string;

@end

#pragma mark -

@implementation J3ReadBuffer

+ (id) buffer
{
  return [[[self alloc] init] autorelease];
}

- (id) init
{
  if (![super init])
    return nil;
  
  dataBuffer = [[NSMutableData alloc] init];
  
  return self;
}

- (void) dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver: nil name: nil object: self];
  [dataBuffer release];
  [super dealloc];
}

- (NSObject *) delegate
{
  return delegate;
}

- (void) setDelegate: (NSObject *) newDelegate
{
  if (delegate)
    [[NSNotificationCenter defaultCenter] removeObserver: delegate name: nil object: self];
  
  delegate = newDelegate;
  
  if ([delegate respondsToSelector: @selector (readBufferDidProvideString:)])
  {
    [[NSNotificationCenter defaultCenter] addObserver: delegate
                                             selector: @selector (readBufferDidProvideString:)
                                                 name: J3ReadBufferDidProvideStringNotification
                                               object: self];
  }
  else
  {
    NSLog (@"[%@ %@] Warning: object of class %@ doesn't respond to %@",
           NSStringFromClass ([self class]),
           NSStringFromSelector (_cmd),
           NSStringFromClass ([newDelegate class]),
           NSStringFromSelector (@selector (readBufferDidProvideString:)));
  }
}

#pragma mark -
#pragma mark J3ReadBuffer protocol

- (void) appendByte: (uint8_t) byte
{
  uint8_t bytes[1] = {byte};
  [self appendBytes: bytes length: 1];
}

- (void) appendBytes: (const uint8_t *) bytes length: (unsigned) length;
{
  [dataBuffer appendData: [NSData dataWithBytes: bytes length: length]];
}

- (const uint8_t *) bytes
{
  return [[self dataValue] bytes];
}

- (void) clear
{
  [dataBuffer setData: [NSData data]];
}

- (NSData *) dataByConsumingBytesToIndex: (unsigned) index
{
  NSData *subdata = [dataBuffer subdataWithRange: NSMakeRange (0, index)];
  
  [dataBuffer setData: [dataBuffer subdataWithRange: NSMakeRange (index, [self length] - index)]];
  
  return subdata;
}

- (NSData *) dataValue
{
  return dataBuffer;
}

- (void) interpretBufferAsString
{
  if ([self length] > 0)
  {
    [self postDidProvideStringNotificationWithString: [[[NSString alloc] initWithBytes: [self bytes]
                                                                                length: [self length]
                                                                              encoding: NSASCIIStringEncoding] autorelease]];
    [self clear];
  }
}

- (BOOL) isEmpty
{
  return [self length] == 0;
}

- (unsigned) length
{
  return [dataBuffer length];
}

@end

#pragma mark -

@implementation J3ReadBuffer (Private)

- (void) postDidProvideStringNotificationWithString: (NSString *) string
{
  [[NSNotificationCenter defaultCenter] postNotificationName: J3ReadBufferDidProvideStringNotification
                                                      object: self
                                                    userInfo: [NSDictionary dictionaryWithObjectsAndKeys: string, @"string", nil]];
}

@end

//
// J3Protocol.h
//
// Copyright (c) 2010 3James Software.
//

#import <Cocoa/Cocoa.h>

@interface J3ByteProtocolHandler : NSObject

+ (id) protocolHandler;

- (NSData *) parseData: (NSData *) data;
- (NSData *) preprocessOutput: (NSData *) data;

@end

#pragma mark -

@interface J3ProtocolStack : NSObject
{
  NSMutableArray *byteProtocolHandlers;
}

- (void) addByteProtocol: (J3ByteProtocolHandler *) protocol;
- (void) clearAllProtocols;

- (NSData *) parseData: (NSData *) data;
- (NSData *) preprocessOutput: (NSData *) data;

@end

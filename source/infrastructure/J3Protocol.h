//
// J3Protocol.h
//
// Copyright (c) 2010 3James Software.
//

#import <Cocoa/Cocoa.h>

@interface J3ProtocolHandler : NSObject

+ (id) protocolHandler;

- (NSData *) parseData: (NSData *) data;
- (NSData *) preprocessOutput: (NSData *) data;

@end

#pragma mark -

@interface J3ProtocolStack : NSObject
{
  NSMutableArray *protocolHandlers;
}

- (void) addProtocol: (J3ProtocolHandler *) protocol;
- (void) clearProtocols;

- (NSData *) parseData: (NSData *) data;
- (NSData *) preprocessOutput: (NSData *) data;

@end

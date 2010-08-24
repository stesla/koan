//
// J3Protocol.h
//
// Copyright (c) 2010 3James Software.
//

#import <Cocoa/Cocoa.h>

@class J3ProtocolStack;

@interface J3ByteProtocolHandler : NSObject
{
  J3ProtocolStack *protocolStack;
}

+ (id) protocolHandlerWithStack: (J3ProtocolStack *) stack;
- (id) initWithStack: (J3ProtocolStack *) stack;

- (void) parseByte: (uint8_t) byte;

- (NSData *) headerForPreprocessedData;
- (NSData *) footerForPreprocessedData;
- (void) preprocessByte: (uint8_t) byte;

@end

#pragma mark -

@interface J3ProtocolStack : NSObject
{
  NSMutableArray *byteProtocolHandlers;
  NSMutableData *parsingBuffer;
  NSMutableData *preprocessingBuffer;
}

- (void) addByteProtocol: (J3ByteProtocolHandler *) protocol;
- (void) clearAllProtocols;

- (NSData *) parseData: (NSData *) data;
- (NSData *) preprocessOutput: (NSData *) data;

- (void) parseByte: (uint8_t) byte previousProtocolHandler: (J3ByteProtocolHandler *) previousHandler;
- (void) preprocessByte: (uint8_t) byte previousProtocolHandler: (J3ByteProtocolHandler *) previousHandler;

@end

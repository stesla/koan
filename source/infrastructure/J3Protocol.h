//
// J3Protocol.h
//
// Copyright (c) 2010 3James Software.
//

#import <Cocoa/Cocoa.h>

@interface J3Protocol : NSObject

+ (id) protocol;

@end

#pragma mark -

@interface J3ProtocolStack : NSObject
{
  NSMutableArray *protocols;
}

- (NSAttributedString *) processAttributedString: (NSAttributedString *) string;
- (void) addProtocol: (J3Protocol *) protocol;
- (void) clearProtocols;

@end

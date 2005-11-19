//
// J3TelnetState.h
//
// Copyright (c) 2005 3James Software
//

#import <Cocoa/Cocoa.h>

@class J3TelnetParser;

@interface J3TelnetState : NSObject 

+ (id) state;

- (J3TelnetState *) parse:(uint8_t)byte forParser:(J3TelnetParser *)parser;

@end

//
//  J3TelnetState.h
//  NewTelnet
//
//  Created by Samuel Tesla on 11/9/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class J3TelnetParser;

@interface J3TelnetState : NSObject 
+ (id) state;
- (J3TelnetState *) parse:(uint8_t)byte forParser:(J3TelnetParser *)parser;
@end

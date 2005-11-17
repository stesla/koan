//
//  J3TelnetParser.h
//  NewTelnet
//
//  Created by Samuel Tesla on 11/9/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "J3Buffer.h"

@class J3TelnetState;

@interface J3TelnetParser : NSObject 
{
  id <NSObject, J3Buffer> inputBuffer;
  id <NSObject, J3Buffer> outputBuffer;
  J3TelnetState * state;
}
+ (id) parser;

- (void) bufferInputByte:(uint8_t)byte;
- (void) bufferOutputByte:(uint8_t)byte;
- (void) parse:(uint8_t)byte;
- (void) parse:(uint8_t *)bytes length:(int)count;

- (void) setInputBuffer:(id <NSObject, J3Buffer>)buffer;
- (void) setOuptutBuffer:(id <NSObject, J3Buffer>)buffer;
@end

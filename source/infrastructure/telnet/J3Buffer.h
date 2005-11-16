//
//  J3Buffer.h
//  NewTelnet
//
//  Created by Samuel Tesla on 11/10/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol J3Buffer
- (void) append:(uint8_t)byte;
- (void) appendLine:(NSString *)line;
- (void) appendString:(NSString *)string;
- (void) clear;
- (NSData *) dataValue;
- (NSString *) stringValue;
@end

@interface J3Buffer : NSObject<J3Buffer>
{
  NSMutableData * buffer;
}
+ (id) buffer;
- (void) setBuffer:(NSData *)buffer;
@end
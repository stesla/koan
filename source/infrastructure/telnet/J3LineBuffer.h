//
//  J3LineBuffer.h
//  NewTelnet
//
//  Created by Samuel Tesla on 11/10/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "J3Buffer.h"

@class J3LineBuffer;

@protocol J3LineBufferDelegate
- (void) lineBufferHasReadLine:(J3LineBuffer *)buffer;
@end

@interface J3LineBuffer : J3Buffer 
{
  id <NSObject, J3LineBufferDelegate> delegate;
}
- (NSString *) readLine;
- (void) setDelegate:(id <NSObject, J3LineBufferDelegate>)object;
@end


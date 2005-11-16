//
//  J3LineBuffer.h
//  NewTelnet
//
//  Created by Samuel Tesla on 11/10/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "J3Buffer.h"

@interface J3LineBuffer : J3Buffer 
{
  id delegate;
}
- (NSString *) readLine;
- (void) setDelegate:(id)object;
@end

@interface NSObject (J3LineBufferDelegate)
- (void) lineBufferHasReadLine:(J3LineBuffer *)buffer;
@end

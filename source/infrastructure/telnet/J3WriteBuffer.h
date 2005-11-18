//
//  J3WriteBuffer.h
//  Koan
//
//  Created by Samuel Tesla on 11/15/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "J3Buffer.h"
#import "J3ByteDestination.h"

@interface J3WriteBufferException : NSException
@end

@interface J3WriteBuffer : J3Buffer 
{
  id <NSObject, J3ByteDestination> destination;
}
- (void) setByteDestination:(id <NSObject, J3ByteDestination>)object;
- (void) write;
- (void) writeUnlessEmpty;
@end

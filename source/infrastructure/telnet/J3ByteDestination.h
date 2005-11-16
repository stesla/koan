//
//  J3ByteDestination.h
//  Koan
//
//  Created by Samuel Tesla on 11/15/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

@protocol J3ByteDestination
- (unsigned int) writeBytes:(const uint8_t *)bytes length:(unsigned int)length;
@end

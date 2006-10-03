//
//  MUProfileFormatting.h
//  Koan
//
//  Created by Samuel on 10/2/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "J3Formatting.h"

@class MUProfile;

@interface MUProfileFormatting : NSObject <J3Formatting>
{
  MUProfile * profile;
}

- (id) initWithProfile:(MUProfile *)newProfile;

@end

//
//  MUServices.h
//  Koan
//
//  Created by Samuel on 1/15/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MUProfileRegistry.h"
#import "MUWorldRegistry.h"

@interface MUServices : NSObject 
{
}

+ (MUProfileRegistry *) profileRegistry;
+ (MUWorldRegistry *) worldRegistry;

@end

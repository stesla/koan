//
//  MUCodingService.h
//  Koan
//
//  Created by Samuel on 1/15/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MUPlayer;
@class MUProfile;
@class MUWorld;

@interface MUCodingService : NSObject 
{
}

+ (void) decodePlayer:(MUPlayer *)player withCoder:(NSCoder *)decoder;
+ (void) decodeProfile:(MUProfile *)profile withCoder:(NSCoder *)decoder;
+ (void) decodeWorld:(MUWorld *)world withCoder:(NSCoder *)decoder;

+ (void) encodePlayer:(MUPlayer *)player withCoder:(NSCoder *)encoder;
+ (void) encodeProfile:(MUProfile *)profile withCoder:(NSCoder *)encoder;
+ (void) encodeWorld:(MUWorld *)world withCoder:(NSCoder *)encoder;

@end

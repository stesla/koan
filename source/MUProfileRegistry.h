//
//  MUProfileRegistry.h
//  Koan
//
//  Created by Samuel on 1/1/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MUWorld;
@class MUProfile;
@class MUPlayer;

@interface MUProfileRegistry : NSObject 
{
  NSMutableDictionary *profiles;
}

+ (MUProfileRegistry *) sharedRegistry;

- (MUProfile *) profileForWorld:(MUWorld *)world;
- (MUProfile *) profileForWorld:(MUWorld *)world player:(MUPlayer *)player;
- (MUProfile *) profileForUniqueIdentifier:(NSString *)worldName;

@end

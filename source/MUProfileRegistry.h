//
// MUProfileRegistry.h
//
// Copyright (c) 2010 3James Software.
//

#import <Cocoa/Cocoa.h>

@class MUWorld;
@class MUProfile;
@class MUPlayer;

@interface MUProfileRegistry : NSObject
{
  NSMutableDictionary *profiles;
}

+ (MUProfileRegistry *) defaultRegistry;

- (NSDictionary *) profiles;
- (void) setProfiles: (NSDictionary *) newProfiles;

- (MUProfile *) profileForProfile: (MUProfile *) profile;
- (MUProfile *) profileForWorld: (MUWorld *) world;
- (MUProfile *) profileForWorld: (MUWorld *) world player: (MUPlayer *) player;
- (MUProfile *) profileForUniqueIdentifier: (NSString *) identifier;

- (BOOL) containsProfile: (MUProfile *) profile;
- (BOOL) containsProfileForWorld: (MUWorld *) world;
- (BOOL) containsProfileForWorld: (MUWorld *) world player: (MUPlayer *) player;
- (BOOL) containsProfileForUniqueIdentifier: (NSString *) identifier;

- (void) removeProfile: (MUProfile *) profile;
- (void) removeProfileForWorld: (MUWorld *) world;
- (void) removeProfileForWorld: (MUWorld *) world player: (MUPlayer *) player;
- (void) removeProfileForUniqueIdentifier: (NSString *) identifier;
- (void) removeAllProfilesForWorld: (MUWorld *) world;

@end

//
// MUProfileRegistry.m
//
// Copyright (c) 2005 3James Software
//

#import "MUProfileRegistry.h"
#import "MUProfile.h"

static MUProfileRegistry *sharedRegistry = nil;

@interface MUProfileRegistry (Private)

- (void) readProfilesFromUserDefaults;
- (void) writeProfilesToUserDefaults;

@end

#pragma mark -

@implementation MUProfileRegistry

+ (MUProfileRegistry *) sharedRegistry
{
  if (!sharedRegistry)
  {
    sharedRegistry = [[MUProfileRegistry alloc] init];
    [sharedRegistry readProfilesFromUserDefaults];
  }
  return sharedRegistry;
}

- (id) init
{
  self = [super init];
  {
    profiles = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (void) dealloc
{
  [profiles release];
  [super dealloc];
}

- (MUProfile *) profileForWorld:(MUWorld *)world
{
  return [self profileForWorld:world player:nil];
}

- (MUProfile *) profileForWorld:(MUWorld *)world player:(MUPlayer *)player
{
  return [self profileForProfile:[MUProfile profileWithWorld:world
                                                      player:player]];
}

- (MUProfile *) profileForProfile:(MUProfile *)profile
{
  MUProfile *rval = [self profileForUniqueIdentifier:[profile uniqueIdentifier]];
  if (!rval)
  {
    rval = profile;
    [profiles setObject:rval forKey:[rval uniqueIdentifier]];    
  }
  return rval;
}

- (MUProfile *) profileForUniqueIdentifier:(NSString *)identifier
{
  return [profiles objectForKey:identifier];
}

- (BOOL) containsProfileForWorld:(MUWorld *)world
{
  return [self containsProfileForWorld:world player:nil];
}

- (BOOL) containsProfileForWorld:(MUWorld *)world player:(MUPlayer *)player
{
  MUProfile *profile = [MUProfile profileWithWorld:world player:player];
  return [self containsProfile:profile];
}

- (BOOL) containsProfile:(MUProfile *)profile
{
  return [self containsProfileForUniqueIdentifier:[profile uniqueIdentifier]];
}

- (BOOL) containsProfileForUniqueIdentifier:(NSString *)identifier;
{
  return [self profileForUniqueIdentifier:identifier] != nil;  
}

- (void) removeProfile:(MUProfile *)profile
{
  [self removeProfileForUniqueIdentifier:[profile uniqueIdentifier]];
}

- (void) removeProfileForWorld:(MUWorld *)world
{
  [self removeProfileForWorld:world player:nil];
}

- (void) removeProfileForWorld:(MUWorld *)world player:(MUPlayer *)player
{
  MUProfile *profile = [self profileForWorld:world player:player];
	
  [self removeProfile:profile];
}

- (void) removeProfileForUniqueIdentifier:(NSString *)identifier
{
  [profiles removeObjectForKey:identifier];  
}

- (void) removeAllProfilesForWorld:(MUWorld *)world
{
  NSArray *players = [world players];
  int i, count = [players count];
  
  for (i = 0; i < count; i++)
  {
    [self removeProfileForWorld:world
                         player:[players objectAtIndex:i]];
  }

  [self removeProfileForWorld:world];
}

- (void) saveProfiles
{
  [self writeProfilesToUserDefaults];
}

- (NSDictionary *) profiles
{
  return profiles;
}

- (void) setProfiles:(NSDictionary *)newProfiles
{
  NSMutableDictionary *copy = [newProfiles mutableCopy];
  [profiles release];
  profiles = copy;
}

@end

#pragma mark -

@implementation MUProfileRegistry (Private)

- (void) readProfilesFromUserDefaults
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSData *profilesData = [defaults dataForKey:MUPProfiles];
  
  if (profilesData)
  {
    [self setProfiles:
      [NSKeyedUnarchiver unarchiveObjectWithData:profilesData]];
  }
}

- (void) writeProfilesToUserDefaults
{
  NSData *data = [NSKeyedArchiver archivedDataWithRootObject:profiles];
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject:data forKey:MUPProfiles];
}

@end

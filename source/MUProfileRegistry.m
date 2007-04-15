//
// MUProfileRegistry.m
//
// Copyright (c) 2007 3James Software.
//

#import "MUProfileRegistry.h"
#import "MUProfile.h"

static MUProfileRegistry *defaultRegistry = nil;

@interface MUProfileRegistry (Private)

- (void) cleanUpDefaultRegistry: (NSNotification *) notification;
- (void) readProfilesFromUserDefaults;
- (void) writeProfilesToUserDefaults;

@end

#pragma mark -

@implementation MUProfileRegistry

+ (MUProfileRegistry *) defaultRegistry
{
  if (!defaultRegistry)
  {
    defaultRegistry = [[MUProfileRegistry alloc] init];
    [defaultRegistry readProfilesFromUserDefaults];
    
    [[NSNotificationCenter defaultCenter] addObserver: defaultRegistry
                                             selector: @selector (cleanUpDefaultRegistry:)
                                                 name: NSApplicationWillTerminateNotification
                                               object: NSApp];
  }
  return defaultRegistry;
}

- (id) init
{
  if (![super init])
    return nil;
  
  profiles = [[NSMutableDictionary alloc] init];
  
  return self;
}

- (void) dealloc
{
  [profiles release];
  [super dealloc];
}

- (MUProfile *) profileForWorld: (MUWorld *) world
{
  return [self profileForWorld: world player: nil];
}

- (MUProfile *) profileForWorld: (MUWorld *) world player: (MUPlayer *) player
{
  return [self profileForProfile: [MUProfile profileWithWorld: world
                                                      player: player]];
}

- (MUProfile *) profileForProfile: (MUProfile *) profile
{
  MUProfile *rval = [self profileForUniqueIdentifier: [profile uniqueIdentifier]];
  if (!rval)
  {
    rval = profile;
    [profiles setObject: rval forKey: [rval uniqueIdentifier]];
    [self writeProfilesToUserDefaults];
  }
  return rval;
}

- (MUProfile *) profileForUniqueIdentifier: (NSString *) identifier
{
  return [profiles objectForKey: identifier];
}

- (BOOL) containsProfileForWorld: (MUWorld *) world
{
  return [self containsProfileForWorld: world player: nil];
}

- (BOOL) containsProfileForWorld: (MUWorld *) world player: (MUPlayer *) player
{
  MUProfile *profile = [MUProfile profileWithWorld: world player: player];
  return [self containsProfile: profile];
}

- (BOOL) containsProfile: (MUProfile *) profile
{
  return [self containsProfileForUniqueIdentifier: [profile uniqueIdentifier]];
}

- (BOOL) containsProfileForUniqueIdentifier: (NSString *) identifier
{
  return [self profileForUniqueIdentifier: identifier] != nil;  
}

- (void) removeProfile: (MUProfile *) profile
{
  [self removeProfileForUniqueIdentifier: [profile uniqueIdentifier]];
}

- (void) removeProfileForWorld: (MUWorld *) world
{
  [self removeProfileForWorld: world player: nil];
}

- (void) removeProfileForWorld: (MUWorld *) world player: (MUPlayer *) player
{
  MUProfile *profile = [self profileForWorld: world player: player];
  
  [self removeProfile: profile];
}

- (void) removeProfileForUniqueIdentifier: (NSString *) identifier
{
  [profiles removeObjectForKey: identifier];  
  [self writeProfilesToUserDefaults];
}

- (void) removeAllProfilesForWorld: (MUWorld *) world
{
  for (unsigned i = 0; i < [[world players] count]; i++)
  {
    [self removeProfileForWorld: world
                         player: [[world players] objectAtIndex: i]];
  }
  
  [self removeProfileForWorld: world];
}

- (NSDictionary *) profiles
{
  return profiles;
}

- (void) setProfiles: (NSDictionary *) newProfiles
{
  if (profiles == newProfiles)
    return;
  
  [profiles release];
  profiles = [newProfiles mutableCopy];
  
  [self writeProfilesToUserDefaults];
}

@end

#pragma mark -

@implementation MUProfileRegistry (Private)

- (void) cleanUpDefaultRegistry: (NSNotification *) notification
{
  [[NSNotificationCenter defaultCenter] removeObserver: defaultRegistry];
  [defaultRegistry release];
}

- (void) readProfilesFromUserDefaults
{
  NSData *profilesData = [[NSUserDefaults standardUserDefaults] dataForKey: MUPProfiles];
  
  if (profilesData)
    [self setProfiles: [NSKeyedUnarchiver unarchiveObjectWithData: profilesData]];
}

- (void) writeProfilesToUserDefaults
{
  [[NSUserDefaults standardUserDefaults] setObject: [NSKeyedArchiver archivedDataWithRootObject: profiles]
                                            forKey: MUPProfiles];
  
  [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

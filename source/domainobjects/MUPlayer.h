//
// MUPlayer.h
//
// Copyright (c) 2007 3James Software.
//

#import <Cocoa/Cocoa.h>
#import "MUWorld.h"

@interface MUPlayer : NSObject <NSCoding, NSCopying>
{
  NSString *name;
  NSString *password;
  MUWorld *world;
}

@property (copy) NSString *name;
@property (copy) NSString *password;
@property (retain) MUWorld *world;

+ (MUPlayer *) playerWithName: (NSString *) newName
  									 password: (NSString *) newPassword
  											world: (MUWorld *) world;

// Designated initializer.
- (id) initWithName: (NSString *) newName
           password: (NSString *) newPassword
              world: (MUWorld *) world;

// Actions.
- (NSString *) loginString;
- (NSString *) uniqueIdentifier;
- (NSString *) windowTitle;

@end

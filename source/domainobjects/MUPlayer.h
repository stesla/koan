//
// MUPlayer.h
//
// Copyright (c) 2004, 2005 3James Software
//

#import <Cocoa/Cocoa.h>
#import "MUWorld.h"

@interface MUPlayer : NSObject <NSCoding, NSCopying>
{
  NSString *name;
  NSString *password;
  MUWorld *world;
}

+ (MUPlayer *) playerWithName:(NSString *)newName
										 password:(NSString *)newPassword
												world:(MUWorld *)world;

// Designated initializer.
- (id) initWithName:(NSString *)newName
           password:(NSString *)newPassword
              world:(MUWorld *)world;

// Accessors.
- (NSString *) name;
- (void) setName:(NSString *)newName;
- (NSString *) password;
- (void) setPassword:(NSString *)newPassword;
- (MUWorld *) world;
- (void) setWorld:(MUWorld *)newWorld;

// Actions.
- (NSString *) loginString;
- (NSString *) uniqueIdentifier;
- (NSString *) windowTitle;

@end

//
// MUPlayer.h
//
// Copyright (C) 2004 3James Software
//

#import <Cocoa/Cocoa.h>
#import "MUWorld.h"

@interface MUPlayer : NSObject <NSCoding, NSCopying>
{
  NSString *name;
  NSString *password;
  MUWorld *world;
}

// Designated initializer.
- (id) initWithName:(NSString *)newName password:(NSString *)newPassword world:(MUWorld *)world;

- (NSString *) name;
- (void) setName:(NSString *)newName;
- (NSString *) password;
- (void) setPassword:(NSString *)newPassword;
- (MUWorld *) world;
- (void) setWorld:(MUWorld *)newWorld;

- (NSString *) loginString;

@end

//
// MUPlayer.h
//
// Copyright (C) 2004, 2005 3James Software
//

#import <Cocoa/Cocoa.h>
#import "MUWorld.h"

@interface MUPlayer : NSObject <NSCoding, NSCopying>
{
  NSString *name;
  NSString *password;
  MUWorld *world;
  
  BOOL connectOnAppLaunch;
}

// Designated initializer.
- (id) initWithName:(NSString *)newName
           password:(NSString *)newPassword
 connectOnAppLaunch:(BOOL)newConnectOnAppLaunch
              world:(MUWorld *)world;

- (NSString *) name;
- (void) setName:(NSString *)newName;
- (NSString *) password;
- (void) setPassword:(NSString *)newPassword;
- (BOOL) connectOnAppLaunch;
- (void) setConnectOnAppLaunch:(BOOL)newConnectOnAppLaunch;
- (MUWorld *) world;
- (void) setWorld:(MUWorld *)newWorld;

- (NSString *) frameName;
- (NSString *) loginString;
- (NSString *) windowName;

@end

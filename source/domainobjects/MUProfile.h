//
//  MUProfile.h
//
// Copyright (C) 2004, 2005 3James Software
//

#import <Cocoa/Cocoa.h>
#import <J3Terminal/J3TelnetConnection.h>
#import "MUWorld.h"
#import "MUPlayer.h"
#import "J3Filter.h"

@interface MUProfile : NSObject 
{
  MUWorld *world;
  MUPlayer *player;
  BOOL loggedIn;
  BOOL autoconnect;
}

+ (MUProfile *) profileWithWorld:(MUWorld *)newWorld 
                          player:(MUPlayer *)newPlayer
                     autoconnect:(BOOL)autoconnect;
+ (MUProfile *) profileWithWorld:(MUWorld *)newWorld player:(MUPlayer *)newPlayer;
+ (MUProfile *) profileWithWorld:(MUWorld *)newWorld;

// Designated initializer.
- (id) initWithWorld:(MUWorld *)newWorld 
              player:(MUPlayer *)newPlayenewAutoconnectr
         autoconnect:(BOOL)autoconnect;
- (id) initWithWorld:(MUWorld *)newWorld player:(MUPlayer *)newPlayer;
- (id) initWithWorld:(MUWorld *)newWorld;

- (NSString *) frameName;
- (NSString *) windowName;

- (NSString *) hostname;
- (NSString *) loginString;
- (J3Filter *) logger;
- (NSString *) uniqueIdentifier;

- (J3TelnetConnection *) openTelnetWithDelegate:(id)delegate;
- (void) loginWithConnection:(J3TelnetConnection *)connection;
- (void) logoutWithConnection:(J3TelnetConnection *)connection;

- (MUWorld *) world;
- (void) setWorld:(MUWorld *)newWorld;
- (MUPlayer *) player;
- (void) setPlayer:(MUPlayer *)newPlayer;
- (BOOL) autoconnect;
- (void) setAutoconnect:(BOOL)newAutoconnect;

@end

//
// MUWorld.h
//
// Copyright (C) 2004 3James Software
//

#import <Cocoa/Cocoa.h>

@class J3TelnetConnection;
@class MUPlayer;

@interface MUWorld : NSObject <NSCoding, NSCopying>
{
  NSString *worldName;
  NSString *worldHostname;
  NSNumber *worldPort;
  NSString *worldURL;
  
  BOOL connectOnAppLaunch;
  
  NSMutableArray *players;
}

// Designated initializer.
- (id) initWithWorldName:(NSString *)newWorldName
           worldHostname:(NSString *)newWorldHostname
               worldPort:(NSNumber *)newWorldPort
                worldURL:(NSString *)newWorldURL
        connectOnAppLaunch:(BOOL)newConnectOnAppLaunch
                 players:(NSArray *)newPlayers;

- (NSString *) worldName;
- (void) setWorldName:(NSString *)newWorldName;
- (NSString *) worldHostname;
- (void) setWorldHostname:(NSString *)newWorldHostname;
- (NSNumber *) worldPort;
- (void) setWorldPort:(NSNumber *)newWorldPort;
- (NSString *) worldURL;
- (void) setWorldURL:(NSString *)newWorldURL;
- (BOOL) connectOnAppLaunch;
- (void) setConnectOnAppLaunch:(BOOL)newConnectOnAppLaunch;
- (NSMutableArray *) players;
- (void) setPlayers:(NSArray *)newPlayers;
- (void) insertObject:(MUPlayer *)player inPlayersAtIndex:(unsigned)index;
- (void) removeObjectFromPlayersAtIndex:(unsigned)index;

- (J3TelnetConnection *) newTelnetConnection;
- (NSString *) frameName;
- (NSString *) windowName;

@end

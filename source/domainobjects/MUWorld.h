//
// MUWorld.h
//
// Copyright (c) 2004, 2005 3James Software
//

#import <Cocoa/Cocoa.h>

@class J3TelnetConnection;
@class J3ProxySettings;
@class MUPlayer;

@interface MUWorld : NSObject <NSCoding, NSCopying>
{
  NSString *worldName;
  NSString *worldHostname;
  NSNumber *worldPort;
  NSString *worldURL;

  BOOL usesSSL;
  BOOL usesProxy;
    
  J3ProxySettings * proxySettings;
  
  NSMutableArray *players;
}

// Designated initializer.
- (id) initWithWorldName:(NSString *)newWorldName
           worldHostname:(NSString *)newWorldHostname
               worldPort:(NSNumber *)newWorldPort
                worldURL:(NSString *)newWorldURL
                 usesSSL:(BOOL)newUsesSSL
           proxySettings:(J3ProxySettings *)newProxySettings
                 players:(NSArray *)newPlayers;

// Accessors.
- (NSString *) worldName;
- (void) setWorldName:(NSString *)newWorldName;
- (NSString *) worldHostname;
- (void) setWorldHostname:(NSString *)newWorldHostname;
- (NSNumber *) worldPort;
- (void) setWorldPort:(NSNumber *)newWorldPort;
- (NSString *) worldURL;
- (void) setWorldURL:(NSString *)newWorldURL;
- (BOOL) usesSSL;
- (void) setUsesSSL:(BOOL)newUsesSSL;
- (J3ProxySettings *) proxySettings;
- (void) setProxySettings:(J3ProxySettings *)newProxySettings;

- (NSMutableArray *) players;
- (void) setPlayers:(NSArray *)newPlayers;
- (void) insertObject:(MUPlayer *)player inPlayersAtIndex:(unsigned)index;
- (void) removeObjectFromPlayersAtIndex:(unsigned)index;
- (void) addPlayer:(MUPlayer *)player;
- (BOOL) containsPlayer:(MUPlayer *)player;
- (void) removePlayer:(MUPlayer *)player;

// Actions.
- (J3TelnetConnection *) newTelnetConnection;
- (NSString *) uniqueIdentifier;
- (NSString *) windowTitle;

@end

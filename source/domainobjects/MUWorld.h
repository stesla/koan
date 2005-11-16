//
// MUWorld.h
//
// Copyright (c) 2004, 2005 3James Software
//

#import <Cocoa/Cocoa.h>

@protocol J3LineBufferDelegate;
@protocol J3SocketDelegate;
@class J3TelnetConnection;
@class J3NewTelnetConnection;
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
               usesProxy:(BOOL)newUsesProxy
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
- (BOOL) usesProxy;
- (void) setUsesProxy:(BOOL)newUsesProxy;
- (J3ProxySettings *) proxySettings;
- (void) setProxySettings:(J3ProxySettings *)newProxySettings;

- (void) addPlayer:(MUPlayer *)player;
- (BOOL) containsPlayer:(MUPlayer *)player;
- (int) indexOfPlayer:(MUPlayer *)player;
- (void) insertObject:(MUPlayer *)player inPlayersAtIndex:(unsigned)index;
- (NSMutableArray *) players;
- (void) removeObjectFromPlayersAtIndex:(unsigned)index;
- (void) removePlayer:(MUPlayer *)player;
- (void) replacePlayer:(MUPlayer *)oldPlayer withPlayer:(MUPlayer *)newPlayer;
- (void) setPlayers:(NSArray *)newPlayers;

// Actions.
- (J3TelnetConnection *) newTelnetConnection;
- (J3NewTelnetConnection *) newTelnetConnectionWithDelegate:(id <NSObject, J3LineBufferDelegate, J3SocketDelegate>)object;
- (NSString *) uniqueIdentifier;
- (NSString *) windowTitle;

@end

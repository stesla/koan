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
  
  BOOL usesSSL;
  BOOL usesProxy;
  
  NSString *proxyHostname;
  NSNumber *proxyPort;
  int proxyVersion;
  NSString *proxyUsername;
  NSString *proxyPassword;
  
  NSMutableArray *players;
}

// Designated initializer.
- (id) initWithWorldName:(NSString *)newWorldName
           worldHostname:(NSString *)newWorldHostname
               worldPort:(NSNumber *)newWorldPort
                worldURL:(NSString *)newWorldURL
      connectOnAppLaunch:(BOOL)newConnectOnAppLaunch
                 usesSSL:(BOOL)newUsesSSL
               usesProxy:(BOOL)newUsesProxy
           proxyHostname:(NSString *)newProxyHostname
               proxyPort:(NSNumber *)newProxyPort
            proxyVersion:(int)newProxyVersion
           proxyUsername:(NSString *)newProxyUsername
           proxyPassword:(NSString *)newProxyPassword
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
- (BOOL) connectOnAppLaunch;
- (void) setConnectOnAppLaunch:(BOOL)newConnectOnAppLaunch;
- (BOOL) usesSSL;
- (void) setUsesSSL:(BOOL)newUsesSSL;
- (BOOL) usesProxy;
- (void) setUsesProxy:(BOOL)newUsesProxy;
- (NSString *) proxyHostname;
- (void) setProxyHostname:(NSString *)newProxyHostname;
- (NSNumber *) proxyPort;
- (void) setProxyPort:(NSNumber *)newProxyPort;
- (int) proxyVersion;
- (void) setProxyVersion:(int)newProxyVersion;
- (NSString *) proxyUsername;
- (void) setProxyUsername:(NSString *)newProxyUsername;
- (NSString *) proxyPassword;
- (void) setProxyPassword:(NSString *)newProxyPassword;

- (NSMutableArray *) players;
- (void) setPlayers:(NSArray *)newPlayers;
- (void) insertObject:(MUPlayer *)player inPlayersAtIndex:(unsigned)index;
- (void) removeObjectFromPlayersAtIndex:(unsigned)index;

// Actions.
- (J3TelnetConnection *) newTelnetConnection;
- (NSString *) frameName;
- (NSString *) windowName;

@end

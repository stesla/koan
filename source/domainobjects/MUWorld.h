//
// MUWorld.h
//
// Copyright (c) 2004, 2005 3James Software
//

#import <Cocoa/Cocoa.h>

@protocol J3LineBufferDelegate;
@protocol J3TelnetConnectionDelegate;
@class J3Telnet;
@class MUPlayer;

@interface MUWorld : NSObject <NSCoding, NSCopying>
{
  NSString *worldName;
  NSString *worldHostname;
  NSNumber *worldPort;
  NSString *worldURL;
  NSMutableArray *players;
}

// Designated initializer.
- (id) initWithWorldName:(NSString *)newWorldName
           worldHostname:(NSString *)newWorldHostname
               worldPort:(NSNumber *)newWorldPort
                worldURL:(NSString *)newWorldURL
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
- (J3Telnet *) newTelnetConnectionWithDelegate:(NSObject <J3LineBufferDelegate, J3TelnetConnectionDelegate> *)delegate;
- (NSString *) uniqueIdentifier;
- (NSString *) windowTitle;

@end

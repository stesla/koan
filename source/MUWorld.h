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
  
  NSMutableArray *players;
}

// Designated initializer.
- (id) initWithWorldName:(NSString *)name
           worldHostname:(NSString *)hostname
               worldPort:(NSNumber *)port
                 players:(NSArray *)newPlayers;

- (NSString *) worldName;
- (void) setWorldName:(NSString *)newWorldName;
- (NSString *) worldHostname;
- (void) setWorldHostname:(NSString *)newHostname;
- (NSNumber *) worldPort;
- (void) setWorldPort:(NSNumber *)newWorldPort;
- (NSMutableArray *) players;
- (void) setPlayers:(NSArray *)newPlayers;
- (void) insertObject:(MUPlayer *)player inPlayersAtIndex:(unsigned)index;
- (void) removeObjectFromPlayersAtIndex:(unsigned)index;

- (J3TelnetConnection *) newTelnetConnection;
- (NSString *) frameName;
- (NSString *) windowName;

@end

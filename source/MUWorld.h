//
// MUWorld.h
//
// Copyright (C) 2004 3James Software
//

#import <Cocoa/Cocoa.h>

@class J3TelnetConnection;

@interface MUWorld : NSObject <NSCoding, NSCopying>
{
  NSString *worldName;
  NSString *worldHostname;
  NSNumber *worldPort;
  
  NSArray *players;
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
- (NSArray *) players;
- (void) setPlayers:(NSArray *)newPlayers;

- (J3TelnetConnection *) newTelnetConnection;

@end

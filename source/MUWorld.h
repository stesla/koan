//
// MUWorld.h
//
// Copyright (C) 2004 3James Software
//

#import <Cocoa/Cocoa.h>
#import <J3Terminal/J3TelnetConnection.h>

@interface MUWorld : NSObject <NSCoding, NSCopying>
{
  NSString *worldName;
  NSString *worldHostname;
  NSNumber *worldPort;
  
  NSDictionary *players;
}

+ (id) connectionWithDictionary:(NSDictionary *)dictionary;

// Designated initializer.
- (id) initWithWorldName:(NSString *)name worldHostname:(NSString *)hostname worldPort:(NSNumber *)port;

- (id) initWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *) objectDictionary;

- (NSString *) worldName;
- (void) setWorldName:(NSString *)newWorldName;
- (NSString *) worldHostname;
- (void) setWorldHostname:(NSString *)newHostname;
- (NSNumber *) worldPort;
- (void) setWorldPort:(NSNumber *)newWorldPort;
- (NSDictionary *) players;
- (void) setPlayers:(NSDictionary *)newPlayers;

- (J3TelnetConnection *) newTelnetConnection;

@end

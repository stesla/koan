//
// MUWorld.h
//
// Copyright (c) 2004, 2005, 2006, 2007 3James Software
//

#import <Cocoa/Cocoa.h>

@protocol J3LineBufferDelegate;
@protocol J3TelnetConnectionDelegate;
@class J3TelnetConnection;
@class MUPlayer;

@interface MUWorld : NSObject <NSCoding, NSCopying>
{
  NSString *name;
  NSString *hostname;
  NSNumber *port;
  NSString *url;
  NSMutableArray *players;
}

+ (MUWorld *) worldWithName: (NSString *) newName
  								 hostname: (NSString *) newHostname
  										 port: (NSNumber *) newPort
  											URL: (NSString *) newURL
  									players: (NSArray *) newPlayers;

// Designated initializer.
- (id) initWithName: (NSString *) newName
           hostname: (NSString *) newHostname
               port: (NSNumber *) newPort
                URL: (NSString *) newURL
            players: (NSArray *) newPlayers;

// Accessors.
- (NSString *) name;
- (void) setName: (NSString *) newName;
- (NSString *) hostname;
- (void) setHostname: (NSString *) newHostname;
- (NSNumber *) port;
- (void) setPort: (NSNumber *) newPort;
- (NSString *) URL;
- (void) setURL: (NSString *) newURL;

// Array-like functions.
- (void) addPlayer: (MUPlayer *) player;
- (BOOL) containsPlayer: (MUPlayer *) player;
- (int) indexOfPlayer: (MUPlayer *) player;
- (void) insertObject: (MUPlayer *) player inPlayersAtIndex: (unsigned) index;
- (NSMutableArray *) players;
- (void) removeObjectFromPlayersAtIndex: (unsigned) index;
- (void) removePlayer: (MUPlayer *) player;
- (void) replacePlayer: (MUPlayer *) oldPlayer withPlayer: (MUPlayer *) newPlayer;
- (void) setPlayers: (NSArray *) newPlayers;

// Actions.
- (J3TelnetConnection *) newTelnetConnectionWithDelegate: (NSObject <J3TelnetConnectionDelegate> *) delegate;
- (NSString *) uniqueIdentifier;
- (NSString *) windowTitle;

@end

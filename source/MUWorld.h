//
// MUWorld.h
//
// Copyright (C) 2004 3James Software
//

#import <Cocoa/Cocoa.h>
#import "MUConstants.h"

@interface MUWorld : NSObject <NSCopying>
{
  NSString *name;
  NSString *hostname;
  NSNumber *port;
  NSDictionary *players;
}

+ (id) connectionWithDictionary:(NSDictionary *)dictionary;

// Designated initializer.
- (id) initWithName:(NSString *)name hostname:(NSString *)hostname port:(NSNumber *)port;

- (id) initWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *) objectDictionary;

- (NSString *) name;
- (void) setName:(NSString *)newName;
- (NSString *) hostname;
- (void) setHostname:(NSString *)newHostname;
- (NSNumber *) port;
- (void) setPort:(NSNumber *)newPort;
- (NSDictionary *) players;
- (void) setPlayers:(NSDictionary *)newPlayers;

@end

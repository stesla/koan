//
// MUConnectionSpec.h
//
// Copyright (C) 2004 3James Software
//

#import <Cocoa/Cocoa.h>
#import "MUConstants.h"

@interface MUConnectionSpec : NSObject <NSCopying>
{
  NSString *name;
  NSString *hostname;
  NSNumber *port;
  NSString *username;
  NSString *password;
}

+ (id) connectionWithDictionary:(NSDictionary *)dictionary;

// Designated initializer.
- (id) initWithName:(NSString *)name hostname:(NSString *)hostname port:(NSNumber *)port username:(NSString *)username password:(NSString *)password;

- (id) initWithDictionary:(NSDictionary *)dictionary;

- (NSString *) name;
- (void) setName:(NSString *)newName;
- (NSString *) hostname;
- (void) setHostname:(NSString *)newHostname;
- (NSNumber *) port;
- (void) setPort:(NSNumber *)newPort;
- (NSString *) username;
- (void) setUsername:(NSString *)newUsername;
- (NSString *) password;
- (void) setPassword:(NSString *)newPassword;

- (NSDictionary *) objectDictionary;

@end

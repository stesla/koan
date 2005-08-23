//
// MUCodingService.h
//
// Copyright (c) 2005 3James Software
//

#import "J3Terminal/J3ProxySettings.h"
#import "MUCodingService.h"
#import "MUProfile.h"

static const int32_t currentProfileVersion = 2;
static const int32_t currentPlayerVersion = 1;
static const int32_t currentWorldVersion = 3;

@interface MUCodingService (Private)

+ (J3ProxySettings *) decodeProxySettingsWithCoder:(NSCoder *)decoder
                                           version:(int)version;

@end

#pragma mark -

@implementation MUCodingService

+ (void) encodePlayer:(MUPlayer *)player withCoder:(NSCoder *)encoder
{
  [encoder encodeInt32:currentPlayerVersion forKey:@"version"];
  
  [encoder encodeObject:[player name] forKey:@"name"];
  [encoder encodeObject:[player password] forKey:@"password"];  
}

+ (void) decodePlayer:(MUPlayer *)player withCoder:(NSCoder *)decoder
{
  // int32_t version = [decoder decodeInt32ForKey:@"version"];
  
  [player setName:[decoder decodeObjectForKey:@"name"]];
  [player setPassword:[decoder decodeObjectForKey:@"password"]];
}

+ (void) encodeProfile:(MUProfile *)profile withCoder:(NSCoder *)encoder
{
  [encoder encodeInt32:currentProfileVersion forKey:@"version"];
  [encoder encodeBool:[profile autoconnect] forKey:@"autoconnect"];
	[encoder encodeObject:[[profile font] fontName] forKey:@"fontName"];
	[encoder encodeFloat:[[profile font] pointSize] forKey:@"fontSize"];
	[encoder encodeObject:[NSArchiver archivedDataWithRootObject:[profile textColor]] forKey:@"textColor"];
	[encoder encodeObject:[NSArchiver archivedDataWithRootObject:[profile backgroundColor]] forKey:@"backgroundColor"];
	[encoder encodeObject:[NSArchiver archivedDataWithRootObject:[profile linkColor]] forKey:@"linkColor"];
	[encoder encodeObject:[NSArchiver archivedDataWithRootObject:[profile visitedLinkColor]] forKey:@"visitedLinkColor"];
}

+ (void) decodeProfile:(MUProfile *)profile withCoder:(NSCoder *)decoder
{
  int32_t version = [decoder decodeInt32ForKey:@"version"];
	
  [profile setAutoconnect:[decoder decodeBoolForKey:@"autoconnect"]];
	
	if (version >= 2)
	{
		[profile setFont:[NSFont fontWithName:[decoder decodeObjectForKey:@"fontName"]
																		 size:[decoder decodeFloatForKey:@"fontSize"]]];
		[profile setTextColor:[NSUnarchiver unarchiveObjectWithData:[decoder decodeObjectForKey:@"textColor"]]];
		[profile setBackgroundColor:[NSUnarchiver unarchiveObjectWithData:[decoder decodeObjectForKey:@"backgroundColor"]]];
		[profile setLinkColor:[NSUnarchiver unarchiveObjectWithData:[decoder decodeObjectForKey:@"linkColor"]]];
		[profile setVisitedLinkColor:[NSUnarchiver unarchiveObjectWithData:[decoder decodeObjectForKey:@"visitedLinkColor"]]];
	}
}

+ (void) encodeWorld:(MUWorld *)world withCoder:(NSCoder *)encoder
{
  J3ProxySettings *theProxySettings = [world proxySettings];
  [encoder encodeInt32:currentWorldVersion forKey:@"version"];
  
  [encoder encodeObject:[world worldName] forKey:@"worldName"];
  [encoder encodeObject:[world worldHostname] forKey:@"worldHostname"];
  [encoder encodeObject:[world worldPort] forKey:@"worldPort"];
  [encoder encodeObject:[world players] forKey:@"players"];
  [encoder encodeObject:[world worldURL] forKey:@"worldURL"];
  [encoder encodeBool:[world usesSSL] forKey:@"usesSSL"];
  [encoder encodeObject:[theProxySettings hostname] forKey:@"proxyHostname"];
  [encoder encodeObject:[NSNumber numberWithInt:[theProxySettings port]] forKey:@"proxyPort"];
  [encoder encodeInt:[theProxySettings version] forKey:@"proxyVersion"];
  [encoder encodeObject:[theProxySettings username] forKey:@"proxyUsername"];
  [encoder encodeObject:[theProxySettings password] forKey:@"proxyPassword"];   
}

+ (void) decodeWorld:(MUWorld *)world withCoder:(NSCoder *)decoder
{
  int32_t version = [decoder decodeInt32ForKey:@"version"];
  
  [world setWorldName:[decoder decodeObjectForKey:@"worldName"]];
  [world setWorldHostname:[decoder decodeObjectForKey:@"worldHostname"]];
  [world setWorldPort:[decoder decodeObjectForKey:@"worldPort"]];
  [world setPlayers:[decoder decodeObjectForKey:@"players"]];
  
  if (version >= 1)
    [world setWorldURL:[decoder decodeObjectForKey:@"worldURL"]];
  else
    [world setWorldURL:@""];
  
  if (version >= 2)
    [world setUsesSSL:[decoder decodeBoolForKey:@"usesSSL"]];
  else
    [world setUsesSSL:NO];
  
  [world setProxySettings:[self decodeProxySettingsWithCoder:decoder 
                                                     version:version]];
  
  if (version >= 3)
    [world setUsesProxy:[decoder decodeBoolForKey:@"usesProxy"]];
  else if ([world proxySettings])
    [world setUsesProxy:YES];
  else
    [world setUsesProxy:NO];
}

@end

#pragma mark -

@implementation MUCodingService (Private)

+ (J3ProxySettings *) decodeProxySettingsWithCoder:(NSCoder *)decoder version:(int)version
{
  NSString *hostname = nil, *username = nil, *password = nil;
  NSNumber *port = [NSNumber numberWithInt:0];
  int newProxyVersion = 5;
  bool usesProxy = NO;
  
  if (version >= 2)
  {
    usesProxy = [decoder decodeBoolForKey:@"usesProxy"];
    hostname = [decoder decodeObjectForKey:@"proxyHostname"];
    port = [decoder decodeObjectForKey:@"proxyPort"];
    newProxyVersion = [decoder decodeIntForKey:@"proxyVersion"];
    username = [decoder decodeObjectForKey:@"proxyUsername"];
    password = [decoder decodeObjectForKey:@"proxyPassword"];
  }
  
  // If this came out nil, then something isn't kosher.
  if (!port)
    return nil;
  
  return [J3ProxySettings settingsWithHostname:hostname port:[port intValue] version:newProxyVersion username:username password:password useProxy:usesProxy];
}

@end

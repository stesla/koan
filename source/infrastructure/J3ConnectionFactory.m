//
//  J3ConnectionFactory.m
//  Koan
//
//  Created by Samuel on 2/22/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "J3ConnectionFactory.h"
#import "J3ProxySettings.h"
#import "J3Socket.h"
#import "J3TelnetParser.h"

static J3ConnectionFactory * currentFactory = nil;

@interface J3ConnectionFactory (Private)

- loadProxySettingsFromDefaults;
- writeProxySettingsToDefaults;

@end

@implementation J3ConnectionFactory

+ (J3ConnectionFactory *) currentFactory;
{
  if (!currentFactory)
  {
    currentFactory = [[self alloc] init];
    [currentFactory loadProxySettingsFromDefaults];
  }
  return currentFactory;
}

- (id) init;
{
  if (![super init])
    return nil;
  useProxy = NO;
  [self at:&proxySettings put:[J3ProxySettings proxySettings]];
  return self;
}

- (J3Telnet *) lineAtATimeTelnetWithHostname:(NSString *)hostname
                                        port:(int)port
                                    delegate:(NSObject <J3TelnetConnectionDelegate> *)delegate
                          lineBufferDelegate:(NSObject <J3LineBufferDelegate> *)lineBufferDelegate;
{  
  J3LineBuffer *buffer = [J3LineBuffer buffer];
  
  [buffer setDelegate:lineBufferDelegate];
  return [self telnetWithHostname:hostname port:port inputBuffer:buffer delegate:delegate];
}

- (J3Telnet *) telnetWithHostname:(NSString *)hostname
                             port:(int)port
                      inputBuffer:(NSObject <J3Buffer> *)buffer
                         delegate:(NSObject <J3TelnetConnectionDelegate> *)delegate
{
  J3TelnetParser *parser;
  J3Socket *socket;
  J3Telnet *result;

  parser = [J3TelnetParser parser];
  [parser setInputBuffer:buffer];
  socket = [J3Socket socketWithHostname:hostname port:port];
  result = [[[J3Telnet alloc] initWithConnection:socket parser:parser delegate:delegate] autorelease];
  [socket setDelegate:result];
  return result;
}

- (J3ProxySettings *) proxySettings;
{
  return proxySettings;
}

- (void) saveProxySettings;
{
  [self writeProxySettingsToDefaults];
}

- (BOOL) toggleUseProxy;
{
  useProxy = !useProxy;
}

- (BOOL) useProxy;
{
  return useProxy;
}

@end

@implementation J3ConnectionFactory (Private)

- loadProxySettingsFromDefaults;
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSData *proxySettingsData = [defaults dataForKey:MUPProxySettings];
  NSData *useProxyData = [defaults dataForKey:MUPUseProxy];
  
  if (proxySettingsData)
    [self at:&proxySettings put:[NSKeyedUnarchiver unarchiveObjectWithData:proxySettingsData]];
  if (useProxyData)
    useProxy = [[NSKeyedUnarchiver unarchiveObjectWithData:useProxyData] boolValue];
}

- writeProxySettingsToDefaults;
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSData *proxySettingsData = [NSKeyedArchiver archivedDataWithRootObject:proxySettings];
  NSData *useProxyData = [NSKeyedArchiver archivedDataWithRootObject:[NSNumber numberWithBool:useProxy]];
  [defaults setObject:proxySettingsData forKey:MUPProxySettings];  
  [defaults setObject:useProxyData forKey:MUPUseProxy];
}

@end

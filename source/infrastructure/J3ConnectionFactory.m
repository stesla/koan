//
// J3ConnectionFactory.m
//
// Copyright (c) 2006 3James Software
//

#import "J3ConnectionFactory.h"
#import "J3ProxySettings.h"
#import "J3ProxySocket.h"
#import "J3Socket.h"
#import "J3TelnetParser.h"

static J3ConnectionFactory *defaultFactory = nil;

@interface J3ConnectionFactory (Private)

- (void) cleanUpDefaultFactory:(NSNotification *)notification;
- (void) loadProxySettingsFromDefaults;
- (void) writeProxySettingsToDefaults;

- (J3Socket *) makeSocketWithHostname:(NSString *)hostname port:(int)port;

@end

#pragma mark -

@implementation J3ConnectionFactory

+ (J3ConnectionFactory *) defaultFactory
{
  if (!defaultFactory)
  {
    defaultFactory = [[self alloc] init];
    [defaultFactory loadProxySettingsFromDefaults];
    
    [[NSNotificationCenter defaultCenter] addObserver:defaultFactory
                                             selector:@selector(cleanUpDefaultFactory:)
                                                 name:NSApplicationWillTerminateNotification
                                               object:NSApp];
  }
  return defaultFactory;
}

- (id) init
{
  if (![super init])
    return nil;
  
  useProxy = NO;
  [self at:&proxySettings put:[J3ProxySettings proxySettings]];
  
  return self;
}

- (void) dealloc
{
  [proxySettings release];
  [super dealloc];
}

- (J3Telnet *) lineAtATimeTelnetWithHostname:(NSString *)hostname
                                        port:(int)port
                                    delegate:(NSObject <J3TelnetConnectionDelegate> *)delegate
                          lineBufferDelegate:(NSObject <J3LineBufferDelegate> *)lineBufferDelegate
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
  socket = [self makeSocketWithHostname:hostname port:port];
  result = [[[J3Telnet alloc] initWithConnection:socket parser:parser delegate:delegate] autorelease];
  [socket setDelegate:result];
  return result;
}

- (J3ProxySettings *) proxySettings
{
  return proxySettings;
}

- (void) saveProxySettings
{
  [self writeProxySettingsToDefaults];
}

- (void) toggleUseProxy
{
  useProxy = !useProxy;
}

- (BOOL) useProxy
{
  return useProxy;
}

@end

#pragma mark -

@implementation J3ConnectionFactory (Private)

- (void) cleanUpDefaultFactory:(NSNotification *)notification
{
  [[NSNotificationCenter defaultCenter] removeObserver:defaultFactory];
  [defaultFactory release];
}

- (void) loadProxySettingsFromDefaults
{
  NSData *proxySettingsData = [[NSUserDefaults standardUserDefaults] dataForKey:MUPProxySettings];
  NSData *useProxyData = [[NSUserDefaults standardUserDefaults] dataForKey:MUPUseProxy];
  
  if (proxySettingsData)
    [self at:&proxySettings put:[NSKeyedUnarchiver unarchiveObjectWithData:proxySettingsData]];
  if (useProxyData)
    useProxy = [[NSKeyedUnarchiver unarchiveObjectWithData:useProxyData] boolValue];
}

- (void) writeProxySettingsToDefaults
{
  NSData *proxySettingsData = [NSKeyedArchiver archivedDataWithRootObject:proxySettings];
  NSData *useProxyData = [NSKeyedArchiver archivedDataWithRootObject:[NSNumber numberWithBool:useProxy]];
  
  [[NSUserDefaults standardUserDefaults] setObject:proxySettingsData forKey:MUPProxySettings];  
  [[NSUserDefaults standardUserDefaults] setObject:useProxyData forKey:MUPUseProxy];
}

- (J3Socket *) makeSocketWithHostname:(NSString *)hostname port:(int)port
{
  if (useProxy)
    return [J3ProxySocket socketWithHostname:hostname port:port proxySettings:proxySettings];
  else
    return [J3Socket socketWithHostname:hostname port:port];
}

@end
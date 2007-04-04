//
// J3SocketFactory.m
//
// Copyright (c) 2006, 2007 3James Software
//

#import "J3SocketFactory.h"
#import "J3ProxySettings.h"
#import "J3ProxySocket.h"
#import "J3Socket.h"
#import "J3TelnetEngine.h"

static J3SocketFactory *defaultFactory = nil;

@interface J3SocketFactory (Private)

- (void) cleanUpDefaultFactory: (NSNotification *) notification;
- (void) loadProxySettingsFromDefaults;
- (void) writeProxySettingsToDefaults;

@end

#pragma mark -

@implementation J3SocketFactory

+ (J3SocketFactory *) defaultFactory
{
  if (!defaultFactory)
  {
    defaultFactory = [[self alloc] init];
    [defaultFactory loadProxySettingsFromDefaults];
    
    [[NSNotificationCenter defaultCenter] addObserver: defaultFactory
                                             selector: @selector (cleanUpDefaultFactory:)
                                                 name: NSApplicationWillTerminateNotification
                                               object: NSApp];
  }
  return defaultFactory;
}

- (id) init
{
  if (![super init])
    return nil;
  
  useProxy = NO;
  [self at: &proxySettings put: [J3ProxySettings proxySettings]];
  
  return self;
}

- (void) dealloc
{
  [proxySettings release];
  [super dealloc];
}

- (J3Socket *) makeSocketWithHostname: (NSString *) hostname port: (int) port
{
  if (useProxy)
    return [J3ProxySocket socketWithHostname: hostname port: port proxySettings: proxySettings];
  else
    return [J3Socket socketWithHostname: hostname port: port];
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

@implementation J3SocketFactory (Private)

- (void) cleanUpDefaultFactory: (NSNotification *) notification
{
  [[NSNotificationCenter defaultCenter] removeObserver: defaultFactory];
  [defaultFactory release];
}

- (void) loadProxySettingsFromDefaults
{
  NSData *proxySettingsData = [[NSUserDefaults standardUserDefaults] dataForKey: MUPProxySettings];
  NSData *useProxyData = [[NSUserDefaults standardUserDefaults] dataForKey: MUPUseProxy];
  
  if (proxySettingsData)
    [self at: &proxySettings put: [NSKeyedUnarchiver unarchiveObjectWithData: proxySettingsData]];
  if (useProxyData)
    useProxy = [[NSKeyedUnarchiver unarchiveObjectWithData: useProxyData] boolValue];
}

- (void) writeProxySettingsToDefaults
{
  NSData *proxySettingsData = [NSKeyedArchiver archivedDataWithRootObject: proxySettings];
  NSData *useProxyData = [NSKeyedArchiver archivedDataWithRootObject: [NSNumber numberWithBool: useProxy]];
  
  [[NSUserDefaults standardUserDefaults] setObject: proxySettingsData forKey: MUPProxySettings];  
  [[NSUserDefaults standardUserDefaults] setObject: useProxyData forKey: MUPUseProxy];
}

@end

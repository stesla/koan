//
// MUGrowlService.m
//
// Copyright (c) 2005 3James Software
//

#import "MUGrowlService.h"
#import <GrowlAppBridge/GrowlApplicationBridge.h>
#import <GrowlAppBridge/GrowlDefines.h>

static BOOL growlAvailable = NO;

@interface MUGrowlService (Private)

+ (void) postGrowlNotificationWithName:(NSString *)name
                                 title:(NSString *)title
                           description:(NSString *)description;
- (void) registerGrowl:(void *)context;

@end

#pragma mark -

@implementation MUGrowlService

+ (void) initializeGrowl
{
  MUGrowlService *temporaryInstance = [[MUGrowlService alloc] init];
  Class growlAppBridge = NSClassFromString (@"GrowlAppBridge");
  
  if (growlAppBridge && [growlAppBridge launchGrowlIfInstalledNotifyingTarget:temporaryInstance
                                                                     selector:@selector(registerGrowl:)
                                                                      context:nil])
  {
    growlAvailable = YES;
  }
  else
  {
    [temporaryInstance release];
  }
}

+ (void) connectionClosedByErrorForTitle:(NSString *)title error:(NSString *)error
{
  NSString *description = [NSString stringWithFormat:NSLocalizedString (MUGConnectionClosedByErrorDescription, nil),
    error];
  
  [self postGrowlNotificationWithName:NSLocalizedString (MUGConnectionClosedByErrorName, nil)
                                title:title
                          description:description];
}

+ (void) connectionClosedByServerForTitle:(NSString *)title
{
  [self postGrowlNotificationWithName:NSLocalizedString (MUGConnectionClosedByServerName, nil)
                                title:title
                          description:NSLocalizedString (MUGConnectionClosedByServerDescription, nil)];
}

+ (void) connectionClosedForTitle:(NSString *)title
{
  [self postGrowlNotificationWithName:NSLocalizedString (MUGConnectionClosedName, nil)
                                title:title
                          description:NSLocalizedString (MUGConnectionClosedDescription, nil)];
}

+ (void) connectionOpenedForTitle:(NSString *)title
{
  [self postGrowlNotificationWithName:NSLocalizedString (MUGConnectionOpenedName, nil)
                                title:title
                          description:NSLocalizedString (MUGConnectionOpenedDescription, nil)];
}

@end

#pragma mark -

@implementation MUGrowlService (Private)

+ (void) postGrowlNotificationWithName:(NSString *)name
                                 title:(NSString *)title
                           description:(NSString *)description
{
  if (growlAvailable)
  {
    NSDictionary *growlNotification = [NSDictionary dictionaryWithObjectsAndKeys: 
      MUApplicationName, GROWL_APP_NAME, 
      name, GROWL_NOTIFICATION_NAME, 
      title, GROWL_NOTIFICATION_TITLE, 
      description, GROWL_NOTIFICATION_DESCRIPTION, 
      [[NSApp applicationIconImage] TIFFRepresentation], GROWL_NOTIFICATION_ICON,
      nil]; 
    
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:GROWL_NOTIFICATION
                                                                   object:GROWL_NOTIFICATION 
                                                                 userInfo:growlNotification
                                                       deliverImmediately:YES];
  }
}

- (void) registerGrowl:(void *)context
{
  if (growlAvailable)
  {
    NSArray *allNotifications = [NSArray arrayWithObjects:
      NSLocalizedString (MUGConnectionOpenedName, nil),
      NSLocalizedString (MUGConnectionClosedName, nil),
      NSLocalizedString (MUGConnectionClosedByServerName, nil),
      NSLocalizedString (MUGConnectionClosedByErrorName, nil),
      nil];
    NSArray *defaultNotifications = [NSArray arrayWithObjects:
      NSLocalizedString (MUGConnectionOpenedName, nil),
      NSLocalizedString (MUGConnectionClosedName, nil),
      NSLocalizedString (MUGConnectionClosedByServerName, nil),
      NSLocalizedString (MUGConnectionClosedByErrorName, nil),
      nil];
    
    NSDictionary *growlRegistration = [NSDictionary dictionaryWithObjectsAndKeys:
      MUApplicationName, GROWL_APP_NAME,
      [[NSApp applicationIconImage] TIFFRepresentation], GROWL_APP_ICON,
      allNotifications, GROWL_NOTIFICATIONS_ALL,
      defaultNotifications, GROWL_NOTIFICATIONS_DEFAULT,
      nil];
    
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:GROWL_APP_REGISTRATION
                                                                   object:nil
                                                                 userInfo:growlRegistration];    
  }
  
  [self release];
}

@end

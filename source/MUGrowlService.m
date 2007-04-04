//
// MUGrowlService.m
//
// Copyright (c) 2007 3James Software. All rights reserved.
//

#import "MUGrowlService.h"

static BOOL growlIsReady = NO;
static MUGrowlService *defaultGrowlService;

@interface MUGrowlService (Private)

- (void) cleanUpDefaultGrowlService: (NSNotification *) notification;
- (void) notifyWithName: (NSString *) name
  								title: (NSString *) title
  					description: (NSString *) description;

@end

#pragma mark -

@implementation MUGrowlService

+ (MUGrowlService *) defaultGrowlService
{
  if (!defaultGrowlService)
  {
    defaultGrowlService = [[MUGrowlService alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver: defaultGrowlService
                                             selector: @selector (cleanUpDefaultGrowlService:)
                                                 name: NSApplicationWillTerminateNotification
                                               object: NSApp];
  }
  return defaultGrowlService;
}

- (id) init
{
  if (![super init])
    return nil;
  
  [GrowlApplicationBridge setGrowlDelegate: self];
  
  return self;
}

+ (void) connectionClosedByErrorForTitle: (NSString *) title error: (NSString *) error
{
  NSString *description = [NSString stringWithFormat: _(MUGConnectionClosedByErrorDescription),
    error];
  
  [[MUGrowlService defaultGrowlService] notifyWithName: _(MUGConnectionClosedByErrorName)
                                                 title: title
                                           description: description];
}

+ (void) connectionClosedByServerForTitle: (NSString *) title
{
  [[MUGrowlService defaultGrowlService] notifyWithName: _(MUGConnectionClosedByServerName)
                                                 title: title
                                           description: _(MUGConnectionClosedByServerDescription)];
}

+ (void) connectionClosedForTitle: (NSString *) title
{
  [[MUGrowlService defaultGrowlService] notifyWithName: _(MUGConnectionClosedName)
                                                 title: title
                                           description: _(MUGConnectionClosedDescription)];
}

+ (void) connectionOpenedForTitle: (NSString *) title
{
  [[MUGrowlService defaultGrowlService] notifyWithName: _(MUGConnectionOpenedName)
                                                 title: title
                                           description: _(MUGConnectionOpenedDescription)];
}

#pragma mark -
#pragma mark GrowlApplicationBridge delegate

- (NSData *) applicationIconDataForGrowl
{
  return [[NSImage imageNamed: @"NSApplicationIcon"] TIFFRepresentation];
}

- (NSString *) applicationNameForGrowl
{
  return MUApplicationName;
}

- (void) growlIsReady
{
  growlIsReady = YES;
}

- (NSDictionary *) registrationDictionaryForGrowl
{
  NSArray *allNotifications = [NSArray arrayWithObjects:
  	_(MUGConnectionOpenedName),
  	_(MUGConnectionClosedName),
  	_(MUGConnectionClosedByServerName),
  	_(MUGConnectionClosedByErrorName),
  	nil];
  NSArray *defaultNotifications = [NSArray arrayWithObjects:
  	_(MUGConnectionOpenedName),
  	_(MUGConnectionClosedName),
  	_(MUGConnectionClosedByServerName),
  	_(MUGConnectionClosedByErrorName),
  	nil];
  
  return [NSDictionary dictionaryWithObjectsAndKeys:
  	allNotifications, GROWL_NOTIFICATIONS_ALL,
  	defaultNotifications, GROWL_NOTIFICATIONS_DEFAULT,
  	nil];
}

@end

#pragma mark -

@implementation MUGrowlService (Private)

- (void) cleanUpDefaultGrowlService: (NSNotification *) notification
{
  [[NSNotificationCenter defaultCenter] removeObserver: defaultGrowlService];
  [defaultGrowlService release];
}

- (void) notifyWithName: (NSString *) name
  								title: (NSString *) title
  					description: (NSString *) description
{
  if (growlIsReady)
  {
  	[GrowlApplicationBridge notifyWithTitle: title
  															description: description
  												 notificationName: name
  																 iconData: nil
  																 priority: 0.0
  																 isSticky: NO
  														 clickContext: nil];
  }
}

@end

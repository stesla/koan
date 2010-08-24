//
// MUGrowlService.m
//
// Copyright (c) 2010 3James Software.
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
  if (!(self = [super init]))
    return nil;
  
  [GrowlApplicationBridge setGrowlDelegate: self];
  
  return self;
}

+ (void) connectionOpenedForTitle: (NSString *) title
{
  [[MUGrowlService defaultGrowlService] notifyWithName: @"Connection opened"
                                                 title: title
                                           description: _(MUGConnectionOpened)];
}

+ (void) connectionClosedForTitle: (NSString *) title
{
  [[MUGrowlService defaultGrowlService] notifyWithName: @"Connection closed"
                                                 title: title
                                           description: _(MUGConnectionClosed)];
}

+ (void) connectionClosedByServerForTitle: (NSString *) title
{
  [[MUGrowlService defaultGrowlService] notifyWithName: @"Connection closed by server"
                                                 title: title
                                           description: _(MUGConnectionClosedByServer)];
}

+ (void) connectionClosedByErrorForTitle: (NSString *) title error: (NSString *) error
{
  NSString *description = [NSString stringWithFormat: _(MUGConnectionClosedByError),
                           error];
  
  [[MUGrowlService defaultGrowlService] notifyWithName: @"Connection closed by error"
                                                 title: title
                                           description: description];
}

#pragma mark -
#pragma mark GrowlApplicationBridge delegate

- (NSString *) applicationNameForGrowl
{
  return MUApplicationName;
}

- (void) growlIsReady
{
  growlIsReady = YES;
}

@end

#pragma mark -

@implementation MUGrowlService (Private)

- (void) cleanUpDefaultGrowlService: (NSNotification *) notification
{
  [[NSNotificationCenter defaultCenter] removeObserver: defaultGrowlService];
  [defaultGrowlService release];
  defaultGrowlService = nil;
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

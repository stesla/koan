//
// MUGrowlService.m
//
// Copyright (c) 2005 3James Software
//

#import "MUGrowlService.h"

static BOOL growlIsReady = NO;
static MUGrowlService *growlService;

@interface MUGrowlService (Private)

- (void) notifyWithName:(NSString *)name
									title:(NSString *)title
						description:(NSString *)description;

@end

#pragma mark -

@implementation MUGrowlService

+ (MUGrowlService *) growlService
{
  if (!growlService)
  {
    growlService = [[MUGrowlService alloc] init];
  }
  return growlService;
}

- (id) init
{
	if (![super init])
    return nil;
  
  [GrowlApplicationBridge setGrowlDelegate:self];
	
	return self;
}

+ (void) connectionClosedByErrorForTitle:(NSString *)title error:(NSString *)error
{
  NSString *description = [NSString stringWithFormat:NSLocalizedString (MUGConnectionClosedByErrorDescription, nil),
    error];
  
  [[MUGrowlService growlService] notifyWithName:NSLocalizedString (MUGConnectionClosedByErrorName, nil)
																					title:title
																		description:description];
}

+ (void) connectionClosedByServerForTitle:(NSString *)title
{
  [[MUGrowlService growlService] notifyWithName:NSLocalizedString (MUGConnectionClosedByServerName, nil)
																					title:title
																		description:NSLocalizedString (MUGConnectionClosedByServerDescription, nil)];
}

+ (void) connectionClosedForTitle:(NSString *)title
{
  [[MUGrowlService growlService] notifyWithName:NSLocalizedString (MUGConnectionClosedName, nil)
																					title:title
																		description:NSLocalizedString (MUGConnectionClosedDescription, nil)];
}

+ (void) connectionOpenedForTitle:(NSString *)title
{
  [[MUGrowlService growlService] notifyWithName:NSLocalizedString (MUGConnectionOpenedName, nil)
																					title:title
																		description:NSLocalizedString (MUGConnectionOpenedDescription, nil)];
}

#pragma mark -
#pragma mark GrowlApplicationBridge delegate

- (NSData *) applicationIconDataForGrowl
{
	return [[NSImage imageNamed:@"NSApplicationIcon"] TIFFRepresentation];
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
	
	return [NSDictionary dictionaryWithObjectsAndKeys:
		allNotifications, GROWL_NOTIFICATIONS_ALL,
		defaultNotifications, GROWL_NOTIFICATIONS_DEFAULT,
		nil];
}

@end

#pragma mark -

@implementation MUGrowlService (Private)

- (void) notifyWithName:(NSString *)name
									title:(NSString *)title
						description:(NSString *)description
{
  if (growlIsReady)
  {
		[GrowlApplicationBridge notifyWithTitle:title
																description:description
													 notificationName:name
																	 iconData:nil
																	 priority:0.0
																	 isSticky:NO
															 clickContext:nil];
  }
}

@end

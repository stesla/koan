//
// MUGrowlService.h
//
// Copyright (c) 2010 3James Software.
//

#import <Cocoa/Cocoa.h>
#import <Growl/GrowlApplicationBridge.h>

@interface MUGrowlService : NSObject <GrowlApplicationBridgeDelegate>

+ (MUGrowlService *) defaultGrowlService;

+ (void) connectionOpenedForTitle: (NSString *) title;
+ (void) connectionClosedForTitle: (NSString *) title;
+ (void) connectionClosedByServerForTitle: (NSString *) title;
+ (void) connectionClosedByErrorForTitle: (NSString *) title error: (NSString *) error;

@end

//
// MUGrowlService.h
//
// Copyright (c) 2005 3James Software
//

#import <Cocoa/Cocoa.h>

@interface MUGrowlService : NSObject

+ (void) initializeGrowl;

+ (void) connectionClosedByErrorForTitle:(NSString *)title error:(NSString *)error;
+ (void) connectionClosedByServerForTitle:(NSString *)title;
+ (void) connectionClosedForTitle:(NSString *)title;
+ (void) connectionOpenedForTitle:(NSString *)title;

@end

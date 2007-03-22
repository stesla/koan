//
// NSObject (DeepMutableCopy).h
//
// Copyright (c) 2004, 2005 3James Software
//
// This file is in the public domain.
//

#import <Cocoa/Cocoa.h>

@protocol NSDeepMutableCopying

- (id) deepMutableCopyWithZone: (NSZone *) zone;

@end

@interface NSObject (DeepMutableCopy)

- (id) deepMutableCopy;

@end

@interface NSArray (DeepMutableCopy)

- (id) deepMutableCopyWithZone: (NSZone *) zone;

@end

@interface NSDictionary (DeepMutableCopy)

- (id) deepMutableCopyWithZone: (NSZone *) zone;

@end

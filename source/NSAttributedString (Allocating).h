//
// NSAttributedString (Allocating).h
//
// Copyright (C) 2004 Tyler Berry and Samuel Tesla
//
// This file is in the public domain.
//

#import <Cocoa/Cocoa.h>

@interface NSAttributedString (Allocating)

+ (NSAttributedString *) attributedStringWithAttributedString:(NSAttributedString *)source;
+ (NSAttributedString *) attributedStringWithString:(NSString *)source;
+ (NSAttributedString *) attributedStringWithString:(NSString *)source attributes:(NSDictionary *)dictionary;

@end
//
// NSAttributedString (Allocating).h
//
// Copyright (c) 2004, 2005 3James Software
//
// This file is in the public domain.
//

#import <Cocoa/Cocoa.h>

@interface NSAttributedString (Allocating)

+ (NSAttributedString *) attributedStringWithAttributedString:(NSAttributedString *)source;
+ (NSAttributedString *) attributedStringWithString:(NSString *)source;
+ (NSAttributedString *) attributedStringWithString:(NSString *)source attributes:(NSDictionary *)dictionary;

@end

@interface NSMutableAttributedString (Allocating)

+ (NSMutableAttributedString *) attributedStringWithAttributedString:(NSAttributedString *)source;
+ (NSMutableAttributedString *) attributedStringWithString:(NSString *)source;
+ (NSMutableAttributedString *) attributedStringWithString:(NSString *)source attributes:(NSDictionary *)dictionary;

@end

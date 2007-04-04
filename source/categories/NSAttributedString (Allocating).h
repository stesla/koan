//
// NSAttributedString (Allocating).h
//
// Copyright (c) 2007 3James Software. All rights reserved.
//
// This file is in the public domain.
//

#import <Cocoa/Cocoa.h>

@interface NSAttributedString (Allocating)

+ (NSAttributedString *) attributedStringWithAttributedString: (NSAttributedString *) source;
+ (NSAttributedString *) attributedStringWithString: (NSString *) source;
+ (NSAttributedString *) attributedStringWithString: (NSString *) source attributes: (NSDictionary *) dictionary;

@end

@interface NSMutableAttributedString (Allocating)

+ (NSMutableAttributedString *) attributedStringWithAttributedString: (NSAttributedString *) source;
+ (NSMutableAttributedString *) attributedStringWithString: (NSString *) source;
+ (NSMutableAttributedString *) attributedStringWithString: (NSString *) source attributes: (NSDictionary *) dictionary;

@end

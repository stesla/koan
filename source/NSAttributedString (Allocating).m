//
// NSAttributedString (Allocating).m
//
// Copyright (C) 2004 3James Software
//
// This file is in the public domain.
//

#import "NSAttributedString (Allocating).h"

@implementation NSAttributedString (Allocating)

+ (NSAttributedString *) attributedStringWithAttributedString:(NSAttributedString *)attributedString
{
  return [[[NSAttributedString alloc] initWithAttributedString:attributedString] autorelease];
}

+ (NSAttributedString *) attributedStringWithString:(NSString *)string
{
  return [[[NSAttributedString alloc] initWithString:string] autorelease];
}

+ (NSAttributedString *) attributedStringWithString:(NSString *)string attributes:(NSDictionary *)dictionary
{
  return [[[NSAttributedString alloc] initWithString:string
                                          attributes:dictionary] autorelease];
}

@end

@implementation NSMutableAttributedString (Allocating)

+ (NSMutableAttributedString *) attributedStringWithAttributedString:(NSAttributedString *)attributedString
{
  return [[[NSMutableAttributedString alloc] initWithAttributedString:attributedString] autorelease];
}

+ (NSMutableAttributedString *) attributedStringWithString:(NSString *)string
{
  return [[[NSMutableAttributedString alloc] initWithString:string] autorelease];
}

+ (NSMutableAttributedString *) attributedStringWithString:(NSString *)string attributes:(NSDictionary *)dictionary
{
  return [[[NSMutableAttributedString alloc] initWithString:string
                                          attributes:dictionary] autorelease];
}

@end
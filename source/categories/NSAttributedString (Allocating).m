//
// NSAttributedString (Allocating).m
//
// Copyright (c) 2004, 2005 3James Software
//
// This file is in the public domain.
//

#import "NSAttributedString (Allocating).h"

@implementation NSAttributedString (Allocating)

+ (NSAttributedString *) attributedStringWithAttributedString:(NSAttributedString *)attributedString
{
  return [[[self alloc] initWithAttributedString:attributedString] autorelease];
}

+ (NSAttributedString *) attributedStringWithString:(NSString *)string
{
  return [[[self alloc] initWithString:string] autorelease];
}

+ (NSAttributedString *) attributedStringWithString:(NSString *)string attributes:(NSDictionary *)dictionary
{
  return [[[self alloc] initWithString:string
                                          attributes:dictionary] autorelease];
}

@end

@implementation NSMutableAttributedString (Allocating)

+ (NSMutableAttributedString *) attributedStringWithAttributedString:(NSAttributedString *)attributedString
{
  return [[[self alloc] initWithAttributedString:attributedString] autorelease];
}

+ (NSMutableAttributedString *) attributedStringWithString:(NSString *)string
{
  return [[[self alloc] initWithString:string] autorelease];
}

+ (NSMutableAttributedString *) attributedStringWithString:(NSString *)string attributes:(NSDictionary *)dictionary
{
  return [[[self alloc] initWithString:string
                                          attributes:dictionary] autorelease];
}

@end

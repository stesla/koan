//
//  MUFormatting.m
//  Koan
//
//  Created by Samuel Tesla on 9/27/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "MUFormatting.h"


@implementation MUFormatting

+ (id) formattingForTesting;
{
  return [self formattingWithForegroundColor:[MUFormatting testingForeground] backgroundColor:[MUFormatting testingBackground] font:[MUFormatting testingFont]];
}

+ (id) formattingWithForegroundColor:(NSColor *)fore backgroundColor:(NSColor *)back font:(NSFont *)font;
{
  return [[[self alloc] initWithForegroundColor:fore backgroundColor:back font:font] autorelease];
}

+ (NSColor *) testingBackground;
{
  return [NSColor blackColor];
}

+ (NSFont *) testingFont;
{
  return [NSFont systemFontOfSize:[NSFont systemFontSize]];
}

+ (NSColor *) testingForeground;
{
  return [NSColor lightGrayColor];
}


- (id) initWithForegroundColor:(NSColor *)fore backgroundColor:(NSColor *)back font:(NSFont *)aFont;
{
  if (!(self = [super init]))
    return nil;
  [self at:&foreground put:fore];
  [self at:&background put:back];
  [self at:&font put:aFont];
  return self;
}

- (NSColor *) background;
{
  return background;
}

- (NSFont *) activeFont;
{
  return font;
}

- (NSColor *) foreground;
{
  return foreground;
}


@end
